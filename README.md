![SharePoint Online](https://img.shields.io/badge/SharePoint-Online-yellow.svg) 
![Windows](https://img.shields.io/static/v1?label=OS&message=Windows&color=green)

# Move-Lists

Easily move SharePoint Online lists from one site to another.

## Move SharePoint Lists

- Download the [latest version of the Move-Lists package](https://github.com/Zerg00s/Move-Lists/releases/download/1.0/Move-Lists.zip).
- Unzip on disk.
- Run `Move-Lists.bat` file.

![](MISC/IMG/Double-click.png)

- Select source SharePoint Online site.
- Select destination SharePoint Online site.

![](MISC/IMG/First-form.png)

- Select one or more Lists or Libraries to migrate.

![](MISC/IMG/Second-form.png)

- Sit back and watch your lists and libraries migrated.

## Limitations
- The script is portable. There is no need to install any PowerShell modules.
- Move-Lists script does not migrate data. Lists and libraries will be empty. 
- macOS and Linux are not supported.
- Does not require local admin privileges.
- Requires Read permission on the Source site.
- Requires Edit permission on the Target site.

## Why would I want to use Move-Lists?
- You need to quickly move multiple lists or libraries.
- You want to migrate Power App and Power Automate flows and you need to make sure lists dependencies exist.
- You don't have a migration tool.
- You don't want or need to write a migration script.
- You don't want to manually re-create custom lists.
- You want to move lists from a DEV to a Production site.
- Migrates list item formatting:

<img style="padding-left:60px" src="MISC/IMG/Formatting.png">