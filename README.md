# Love2D base template

A project template with some libraries and snippets I often use for my projects.

- **src**: A folder with all the game files, including code, libraries, sounds and sprites

- **bin**: Files used to build executables.

- **build.sh** & **build.ps1**: Build scripts for Linux and Windows, respectively. The final executable will be inside the `_build` folder. Example: `build [windows|linux|web|lovefile|all]`

- **publish.sh**: Uploads the most recent build of each platform to Itch.io using Butler. Example: `publish <version>`