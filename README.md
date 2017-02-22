# Dockerized Neovim
Run neovim in a container and be cool like all the other cool kids.
I'm currently trying to have as little dependancies installed on my host machine as possible.

# Step 1: Build the image
The are 2 small steps that occur in this step.
First we build the binaries for shellcheck, because I want to only have couple of MB's in binaries vs installing haskell.
This creates a folder called 'package' at the root directory which we then import to our main neovim image.
The second step is actually compiling the the neovim package which is just installing some stuff and copying the binaries.
This can all be done with a single make command.
```
$ make build
```

# Step 2: Run the image
Say you have a local file called 'test.php' and you are in the same directory as the file.
To open that file with the neovim container simply run the following
```
$ docker run -i -t -v $(pwd):/src thornycrackers/neovim /bin/sh -c 'nvim /src/test.php'
```
This will open up neovim and when you exit neovim it will exit the container.

# Step 3: Make this command a little more useful
So using that command is awesome but a little cumbersome everytime you want to run it against a different file.
Create a file called 'nvim' and make sure to give it executable permissions and place it somewhere in your $PATH.
Copy the following inside of the 'nvim' executable file.

```
#!/bin/bash
# Command for running neovim

if [[ "$1" = /* ]]; then
  file_name="$(basename ${1})"
  dir_name="$(dirname ${1})"
else
  file_name="$1"
  dir_name="$(pwd)"
fi

# Run the docker command
docker run -i -t -P -v "$dir_name":/src thornycrackers/neovim /bin/sh -c "cd /src;nvim $file_name"
```

Now you can run neovim as if you would regularly.
The only gotcha I've deiscovered so far is that because you are mounting to the docker container you cannot go above the folder you open neovim in.
This is a pretty rare case in my trials of using this but it is something to note.
