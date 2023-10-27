## commandline history.
# making the commandline history work is actually a thing you have to do.
# most shells won't save the commands you run until they close, i think? 
# so shells will overwrite eachother's local saved history file, and it's basically useless.
# this is how we fix it.

To configure your shell to save command history after every message, you can follow these general steps:

    Determine your shell: Identify which shell you're using. The most common shells are Bash, Zsh, and Fish. You can check your current shell by running the echo $SHELL command.

    Locate your shell configuration file: The location and name of the configuration file may vary depending on your shell. Here are the default configuration files for some popular shells:
        Bash: ~/.bashrc or ~/.bash_profile
        Zsh: ~/.zshrc
        Fish: ~/.config/fish/config.fish

    Open the configuration file in a text editor.

    Add the following lines to the configuration file:

        For Bash:

        bash

shopt -s histappend
PROMPT_COMMAND='history -a'

For Zsh:

bash

setopt inc_append_history
setopt share_history

For Fish:

bash

        set -U fish_history $HOME/.config/fish/fish_history

        This will save your fish shell history to the specified file.

    Save the changes and exit the text editor.

    Restart your shell or run the appropriate command to reload the configuration file. For example:
        For Bash: Run source ~/.bashrc or source ~/.bash_profile.
        For Zsh: Run source ~/.zshrc.
        For Fish: No additional action is needed.

After making these changes, your shell history should be saved after every command. You can test it by running some commands and then checking the history using the history command or by pressing the Up arrow key to navigate through your command history.

Note that if you switch between different shells or terminal emulators, you may need to repeat these steps for each shell or terminal emulator you use.
