# ------------------------------------------------------------------------------
# --          ____  _____________  __                                         --
# --         / __ \/ ____/ ___/\ \/ /                 _   _   _               --
# --        / / / / __/  \__ \  \  /                 / \ / \ / \              --
# --       / /_/ / /___ ___/ /  / /               = ( M | S | K )=            --
# --      /_____/_____//____/  /_/                   \_/ \_/ \_/              --
# --                                                                          --
# ------------------------------------------------------------------------------
# --! @copyright (c) 2023 DESY
# --! SPDX-License-Identifier: Apache-2.0
# ------------------------------------------------------------------------------
# --! @date 2023-05-31
# --! @author Burak Dursun <burak.dursun@desy.de>
# ------------------------------------------------------------------------------
# --! @brief renders jinja2 template using command line json arguments
# ------------------------------------------------------------------------------

import sys
import os
import json
import jinja2
from pathlib import PurePath

context = json.loads(sys.argv[1])

searchpath = PurePath(os.getcwd()).drive + "/"
templateLoader = jinja2.FileSystemLoader(searchpath=searchpath)
templateEnv = jinja2.Environment(loader=templateLoader)
# as_posix() ensures forward slashes on Windows
templatePath = PurePath(sys.argv[2]).relative_to(searchpath).as_posix()
template = templateEnv.get_template(templatePath)
generate = template.render(context)

with open(sys.argv[3], "w", encoding="utf-8") as fh:
  fh.write(generate)
