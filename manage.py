#!/usr/bin/env python
import os

try:
    this_file = os.path.dirname(os.path.abspath(__file__)) + '/venv/bin/activate_this.py'
    execfile(this_file, dict(__file__=this_file))
except:
    pass

import sys

if __name__ == "__main__":
    os.environ.setdefault("DJANGO_SETTINGS_MODULE", "sscloud.settings")

    from django.core.management import execute_from_command_line

    execute_from_command_line(sys.argv)
