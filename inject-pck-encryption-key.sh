#!/bin/bash
# Injects a PCK encryption key into an export template. You should only call
# from CI pipelines that sanitize logs, because otherwise you will leave secrets
# in your ~/.bash_history.
# Args:
# $1: Name of the export template.
# $2: PCK encryption key
#
# Authored by Speedyvelcro, 2026
#
# This is free and unencumbered software released into the public domain.
#
# Anyone is free to copy, modify, publish, use, compile, sell, or
# distribute this software, either in source code form or as a compiled
# binary, for any purpose, commercial or non-commercial, and by any
# means.
#
# In jurisdictions that recognize copyright laws, the author or authors
# of this software dedicate any and all copyright interest in the
# software to the public domain. We make this dedication for the benefit
# of the public at large and to the detriment of our heirs and
# successors. We intend this dedication to be an overt act of
# relinquishment in perpetuity of all present and future rights to this
# software under copyright law.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
# For more information, please refer to <https://unlicense.org/>

echo "Starting key injection script for $1"

expected_line="script_encryption_key=\"$2\""

name_pattern='^"?'$1'"?$' # Whole name, because sometimes names contain other names (e.g. game_jolt-web contains web), and possibly quoted in the cfg file

# NB: $1 and $2 used here are awk fields, not the bash parameters.
header=$(gawk -v name_pattern="$name_pattern" -F "=" \
    '/^\[preset\.[0-9]+\]$/ {header=$0} \
    $1 == "name" && $2 ~ name_pattern {printf "%s", header}' \
    export_presets.cfg)

echo "Header corresponding to ${1}: ${header}"

# There are 4 cases to deal with here:
# 1) file doesn't exist
# 2) file does exist but doesn't have the header
# 3) file does exist and has the header, but doesn't have script_encryption_key
# 4) file does exist and has the header and a (likely incorrect or empty) script_encryption_key
# This tangle of if statements deals with all of them.
if [ -e .godot/export_credentials.cfg  ]; then
    echo "Credentials file already exists."
    if grep -Fq "$header" .godot/export_credentials.cfg; then
        echo "Found header ${header} in credentials file."
        # 4) file does exist and has the header and a (likely incorrect or empty) script_encryption_key
        # (called for both cases 3 and 4, but that's fine because this awk command does nothing for case 3 anyway)
        echo "Attempting to insert key into existing script_encryption_key line..."
        gawk -i inplace -v expected_line="$expected_line" -v correct_header="$header" \
            '/^\[.*\]$/ {header=$0} \
            { if(header == correct_header) sub(/script_encryption_key=".*"/,expected_line) } \
            { print }' \
            .godot/export_credentials.cfg

        if gawk -v expected_line="$expected_line" -v correct_header="$header" \
                '/^\[.*\]$/ {header=$0} \
                header == correct_header && $0 == expected_line { exit 1 }' \
                .godot/export_credentials.cfg; then
            echo "The insertion failed. The script_encryption_key line probably doesn't exist."
            echo "Inserting encryption key as new script_encryption_key line instead..."
            # 3) file does exist and has the header, but doesn't have script_encryption_key
            gawk -i inplace -v line_to_insert="$expected_line" -v under_header="$header" \
                '{ print } \
                $0 == under_header { print line_to_insert }' \
                .godot/export_credentials.cfg
        fi
    else
        echo "Did not find header ${header} in credentials file."
        # 2) file does exist but doesn't have the header

        echo "Inserting header and script_encryption_key line..."
        # Extra line just in case there is no newline at the end. No-one cares if we end up with excessive whitespace.
        echo "" >> .godot/export_credentials.cfg
        echo "$header" >> .godot/export_credentials.cfg
        echo $expected_line >> .godot/export_credentials.cfg
    fi
else
    echo "Credentials file does not exist."
    # 1) file doesn't exist

    echo "Creating a new one..."
    mkdir -p .godot
    echo "$header" > .godot/export_credentials.cfg
    echo $expected_line >> .godot/export_credentials.cfg
fi

echo "Done!"
