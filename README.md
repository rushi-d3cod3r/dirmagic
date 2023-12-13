# DirMagic a Directory-organizer

![image](/assets/DirMagic.png)

## What is DirMagic ?
A bash script to organise your files either by extension or by Date
#### Platforms Tested:
 + Debian based Linux

## Installation

Installing using command line
```bash
$ git clone https://github.com/rushi-d3cod3r/dirmagic.git
$ cd dirmagic 
$ chmod +x DirMagic.sh 
$ mv DirMagic.sh /usr/bin

```

## Usage

```bash
Dirmagic.sh -h { To show help/usage }

#To organise files by their extension
DirMagic.sh source_dir Dest_dir -s ext 

#To organise files by their modification Date
Dirmagic.sh source_dir Dest_dir -s date

#To exclude the specific files 
DirMagic.sh source_dir Dest_dir -e [File Type] -s ext 

#To delete original Files 
DirMagic.sh source_dir Dest_dir -e [File Type] -s ext -d
#above will exclude the given files from deleting also 


```

## Contributing

Pull requests are welcome. For major changes, please open an issue first
to discuss what you would like to change.

Please make sure to update tests as appropriate.
