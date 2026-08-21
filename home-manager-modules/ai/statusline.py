"""Claude Code status line: one reading row above a full-bleed context rule."""
import fcntl
import json
import os
import re
import shutil
import struct
import subprocess
import sys
import termios
import time

TEXT, DIM, TRACK = "a6adc8", "6c7086", "313244"
ACCENT, WARN, CRIT = "89b4fa", "f9e2af", "f38ba8"
WARN_AT, CRIT_AT = 60, 85

RESET = "\x1b[0m"
GLYPH_BRANCH = ""
GLYPH_5H = ""
GLYPH_7D = ""
GLYPH_DIR = ""
RULE = "━"
GAP = "   "


def fg(h):
    r, g, b = (int(h[i:i + 2], 16) for i in (0, 2, 4))
    return "\x1b[38;2;%d;%d;%dm" % (r, g, b)


def band(pct):
    return CRIT if pct >= CRIT_AT else WARN if pct >= WARN_AT else ACCENT


def visible(row):
    """Cell count of a rendered row, discarding the SGR sequences."""
    return len(re.sub(r"\x1b\[[0-9;]*m", "", row))


def tilde(path):
    home = os.path.expanduser("~")
    if path == home:
        return "~"
    if path.startswith(home + os.sep):
        return "~" + path[len(home):]
    return path


def compact_window():
    """Auto-compact fires at this token count. The env var and the settings key
    are the only sources exposed to a status line; the --autocompact flag is
    not reflected in either."""
    env = os.environ.get("CLAUDE_CODE_AUTO_COMPACT_WINDOW")
    if env:
        try:
            return int(env)
        except ValueError:
            pass
    try:
        with open(os.path.expanduser("~/.claude/settings.json")) as fh:
            settings = json.load(fh)
    except (OSError, ValueError):
        return None
    if settings.get("autoCompactEnabled") is False:
        return None
    value = settings.get("autoCompactWindow")
    return int(value) if isinstance(value, (int, float)) else None


def terminal_width():
    """COLUMNS is captured once when the session starts and does not follow a
    resize. The status line is spawned without a controlling terminal, so the
    live size comes from the terminal device of the nearest ancestor that has
    one, found through its tty_nr rather than through an inherited descriptor."""
    pid = os.getpid()
    for _ in range(6):
        try:
            stat = open("/proc/%d/stat" % pid).read()
            fields = stat[stat.rindex(")") + 2:].split()
            tty_nr, parent = int(fields[4]), int(fields[1])
        except (OSError, ValueError, IndexError):
            break
        if tty_nr >> 8 & 0xff == 136:
            minor = (tty_nr & 0xff) | (tty_nr >> 12 & 0xfff00)
            try:
                fd = os.open("/dev/pts/%d" % minor, os.O_RDONLY | os.O_NOCTTY)
                try:
                    size = fcntl.ioctl(fd, termios.TIOCGWINSZ,
                                       struct.pack("HHHH", 0, 0, 0, 0))
                finally:
                    os.close(fd)
                cols = struct.unpack("HHHH", size)[1]
                if cols:
                    return cols
            except OSError:
                pass
        if parent <= 1:
            break
        pid = parent
    return shutil.get_terminal_size((80, 24)).columns


def rate_window(obj):
    pct = obj.get("used_percentage")
    at = obj.get("resets_at")
    stamp = ""
    if at is not None:
        reset = time.localtime(at)
        same_day = reset[:3] == time.localtime()[:3]
        stamp = time.strftime("%H:%M" if same_day else "%m-%d %H:%M", reset)
    return (None if pct is None else float(pct)), stamp


def reading(glyph, pct, stamp):
    """A percentage carries hue only once it is worth looking at, so at rest the
    whole row is grey and the rule below is the only coloured thing on screen."""
    out = fg(DIM) + glyph + " " + fg(band(pct) if pct >= WARN_AT else TEXT)
    out += "%d%%" % round(pct)
    if stamp:
        out += fg(DIM) + " " + stamp
    return out


def main():
    try:
        data = json.load(sys.stdin)
    except (ValueError, OSError):
        return

    model = data.get("model", {}).get("display_name", "")
    effort = data.get("effort", {}).get("level", "")
    space = data.get("workspace") or {}
    cwd = space.get("project_dir") or space.get("current_dir") or data.get("cwd", "")

    branch = ""
    if cwd:
        try:
            branch = subprocess.run(
                ["git", "-C", cwd, "--no-optional-locks", "branch", "--show-current"],
                capture_output=True, text=True, timeout=1).stdout.strip()
        except (OSError, subprocess.SubprocessError):
            pass

    cw = data.get("context_window") or {}
    size = cw.get("context_window_size") or 0
    tokens = cw.get("total_input_tokens")
    if tokens is None:
        raw = cw.get("used_percentage")
        tokens = None if raw is None or not size else raw / 100.0 * size
    # Scaled against the auto-compact window, not context_window_size:
    # compaction fires at autoCompactWindow tokens, so on a 1M model with a
    # 200k compact window the raw percentage never leaves the first cells.
    limit = compact_window() or size
    ctx = None if tokens is None or not limit else tokens / limit * 100.0

    rl = data.get("rate_limits") or {}
    five, five_at = rate_window(rl.get("five_hour") or {})
    week, week_at = rate_window(rl.get("seven_day") or {})

    place = []
    if model:
        place.append(fg(TEXT) + model)
    if effort:
        place.append(fg(DIM) + effort)
    if cwd:
        head, sep, tail = tilde(cwd).rpartition("/")
        place.append(fg(DIM) + GLYPH_DIR + " " + head + sep + fg(TEXT) + tail)
    if branch:
        place.append(fg(DIM) + GLYPH_BRANCH + " " + branch)

    readings = []
    if five is not None:
        readings.append(reading(GLYPH_5H, five, five_at))
    if week is not None:
        readings.append(reading(GLYPH_7D, week, week_at))

    # One cell short: a single overhanging cell wraps into a stray line of its
    # own. Width is only ever used to drop items, never to position them, so a
    # wrong guess costs at worst a shortened row.
    width = terminal_width() - 1

    rows = []
    if place or readings:
        # The readings outrank where you are, so the row sheds its rightmost
        # place item until what is left fits.
        row = GAP.join(place + readings)
        while place and visible(row) > width:
            place.pop()
            row = GAP.join(place + readings)
        rows.append(row + RESET)
    if ctx is not None:
        # The rule underlines the row above rather than spanning the terminal:
        # it is measured, not inferred, so it cannot overhang and wrap.
        suffix = " %d%%" % round(ctx)
        span = max((visible(rows[0]) if rows else width) - len(suffix), 0)
        filled = int(round(ctx / 100.0 * span))
        rows.append(fg(band(ctx)) + RULE * filled
                    + fg(TRACK) + RULE * (span - filled)
                    + fg(band(ctx) if ctx >= WARN_AT else DIM) + suffix + RESET)

    sys.stdout.write("\n".join(rows))


if __name__ == "__main__":
    main()
