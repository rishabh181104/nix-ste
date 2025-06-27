# =============================================================================
#                           STECORE DOTFILES
# =============================================================================
# Fish Shell Custom Prompt Function
# A beautiful and informative command prompt for Fish shell
# 
# Features:
# - Git and Mercurial repository status display
# - Color-coded command exit status
# - Current directory display
# - Repository branch and dirty state indicators
# - Root user detection
# =============================================================================

function fish_prompt
    # =============================================================================
    # INITIALIZATION
    # =============================================================================
    # Store the exit status of the last command
    set -l __last_command_exit_status $status

    # =============================================================================
    # HELPER FUNCTIONS DEFINITION (Only defined once)
    # =============================================================================
    if not set -q -g __fish_arrow_functions_defined
        set -g __fish_arrow_functions_defined
        
        # Get current Git branch name
        function _git_branch_name
            set -l branch (git symbolic-ref --quiet HEAD 2>/dev/null)
            if set -q branch[1]
                echo (string replace -r '^refs/heads/' '' $branch)
            else
                echo (git rev-parse --short HEAD 2>/dev/null)
            end
        end

        # Check if Git repository has uncommitted changes
        function _is_git_dirty
            not command git diff-index --cached --quiet HEAD -- &>/dev/null
            or not command git diff --no-ext-diff --quiet --exit-code &>/dev/null
        end

        # Check if current directory is a Git repository
        function _is_git_repo
            type -q git
            or return 1
            git rev-parse --git-dir >/dev/null 2>&1
        end

        # Get current Mercurial branch name
        function _hg_branch_name
            echo (hg branch 2>/dev/null)
        end

        # Check if Mercurial repository has uncommitted changes
        function _is_hg_dirty
            set -l stat (hg status -mard 2>/dev/null)
            test -n "$stat"
        end

        # Check if current directory is a Mercurial repository
        function _is_hg_repo
            fish_print_hg_root >/dev/null
        end

        # Generic function to get repository branch name
        function _repo_branch_name
            _$argv[1]_branch_name
        end

        # Generic function to check repository dirty state
        function _is_repo_dirty
            _is_$argv[1]_dirty
        end

        # Determine repository type (git or hg)
        function _repo_type
            if _is_hg_repo
                echo hg
                return 0
            else if _is_git_repo
                echo git
                return 0
            end
            return 1
        end
    end

    # =============================================================================
    # COLOR DEFINITIONS
    # =============================================================================
    set -l cyan (set_color -o cyan)      # Directory color
    set -l yellow (set_color -o yellow)  # Dirty state color
    set -l red (set_color -o red)        # Error and branch color
    set -l green (set_color -o green)    # Success color
    set -l blue (set_color -o blue)      # Repository type color
    set -l normal (set_color normal)     # Reset color

    # =============================================================================
    # PROMPT ARROW (Status-based coloring)
    # =============================================================================
    # Set arrow color based on last command exit status
    set -l arrow_color "$green"
    if test $__last_command_exit_status != 0
        set arrow_color "$red"
    end

    # Choose arrow symbol based on user privileges
    set -l arrow "$arrow_color➜ "
    if fish_is_root_user
        set arrow "$arrow_color# "  # Use # for root user
    end

    # =============================================================================
    # CURRENT DIRECTORY DISPLAY
    # =============================================================================
    # Show only the current directory name (not full path)
    set -l cwd $cyan(basename (prompt_pwd))

    # =============================================================================
    # REPOSITORY INFORMATION
    # =============================================================================
    set -l repo_info
    if set -l repo_type (_repo_type)
        # Display repository type and branch name
        set -l repo_branch $red(_repo_branch_name $repo_type)
        set repo_info "$blue $repo_type:($repo_branch$blue)"

        # Add dirty state indicator if repository has uncommitted changes
        if _is_repo_dirty $repo_type
            set -l dirty "$yellow ✗"
            set repo_info "$repo_info$dirty"
        end
    end

    # =============================================================================
    # PROMPT OUTPUT
    # =============================================================================
    # Combine all elements: arrow, directory, repository info, and reset color
    echo -n -s $arrow ' '$cwd $repo_info $normal ' '
end
