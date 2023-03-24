#!/bin/bash
# Check if correct number of arguments were passed
if [ $# -lt 1 ]; then
    echo "Usage: $0 option [arguments]"
    echo "Options: setup, enum"
    echo "	   setup -   Setup the environment (To include go, gospider, paramspider, waybackurls, gau, gf, etc...)"
    echo "	   enum -    Perform web application enumeration" 
    exit 1
fi


# Set option and shift arguments
option=$1
shift
RC=""

# Determine Current Shell
if echo $SHELL | grep -q "bash"; then
    RC=".bashrc"
elif echo $SHELL | grep -q "zsh"; then
    RC=".zshrc"
else
    echo "Current shell is not bash or zsh.... edit this file and replace the RC variable with your current Shell Runtime Configuration file name (E.G. .bashrc)"
    RC="REPLACE_VALUE_HERE"
    exit 1
fi

# Input validation
if [ "$option" != "setup" ] && [ "$option" != "enum" ]; then
    echo -e "\033[31mError: Invalid option selected. Please choose 'setup' or 'enum'.\033[32m" >&2
    exit 1
fi


# Setup option 
if [ "$option" == "setup" ]; then
    mkdir -p "dist"
    sudo apt update
    #Update function for GO
    function updateGo() {
        cd dist/
        wget https://go.dev/dl/go1.19.4.linux-amd64.tar.gz
        tar -xzvf go1.19.4.linux-amd64.tar.gz
        sudo mv go /usr/lib/go-1.19
        sudo ln -sf /usr/lib/go-1.19/ /usr/lib/go
        sudo ln -sf /usr/lib/go-1.19/bin/go /usr/bin/go
        GO_VERSION=$(go version | awk '{print $3}')
        if [[ "$GO_VERSION" < "go1.18" ]]; then
            echo -e "\033[31mError: Failed Updating Go Version.... exiting\033[0m"
            exit 1
        fi
        cd ..
    }

    # Check if Go is installed
    if ! [ -x "$(command -v go)" ]; then
        echo -e "\033[32m"
        echo 'Installing GO'
        echo -e "\033[0m"
        sudo apt install -y golang
        if ! [ -x "$(command -v go)" ]; then
            echo -e "\033[32m"
            echo "Error: Unable to install go...."
            echo "Do you want to install go from its source code on github using this script? (yes/no)"
            read -r user_input
            echo -e "\033[0m"
            if [ "$user_input" = "yes" ] || [ "$user_input" = "y" ]; then
                updateGo
            else 
                exit 1
            fi
        fi
    fi

    # Go version needs to be atleast 1.17+
    GO_VERSION=$(go version | awk '{print $3}')
    if [[ "$GO_VERSION" < "go1.18" ]]; then
        echo -e "\033[32m"
        echo "Error: Go version is less than 1.18, please update Go and try again."
        echo "Do you want to upgrade the GO version using this script? (yes/no)"
        read -r user_input
        echo -e "\033[0m"
        if [ "$user_input" = "yes" ] || [ "$user_input" = "y" ]; then
            updateGo
        else 
            exit 1
        fi
    fi

    # Check if GOPATH is set
    if [ -z "$GOPATH" ]; then
        echo -e "\033[32m"
        echo " "
        echo 'You need to setup your go environment. perform the following and then re-run the setup:'
        echo "-------------------------------------------------------------------------------------------"
        echo "echo \"export GOROOT=/usr/lib/go\" >> ~/${RC}"
        echo "echo \"export GOPATH=\$HOME/go\" >> ~/${RC}"
        echo "echo \"export PATH=\$GOPATH/bin:\$GOROOT/bin:\$PATH\" >> ~/${RC}"
        echo "source ~/${RC}"
        echo "-------------------------------------------------------------------------------------------"
        echo " "
      exit 1
    fi

    if ! [ -x "$(command -v python3)" ]; then
        echo -e "\033[32mInstalling python3...\033[0m"
        sudo apt install python3
        if ! [ -x "$(command -v python3)" ]; then
            echo "Error: Python3 failed to install, please install python3 and try again."
            exit 1
        fi

    fi

    if ! [ -x "$(command -v pip3)" ]; then
        echo -e "\033[32mInstalling pip3...\033[0m"
        sudo apt install python3-pip
        if ! [ -x "$(command -v pip3)" ]; then
            echo "Error: Pip3 failed to install, please install python3-pip and try again."
            exit 1
        fi

    fi

    # Check if httprobe is installed
    if ! [ -x "$(command -v httprobe)" ]; then
        echo -e "\033[32mInstalling httprobe....\033[0m"
        go install github.com/tomnomnom/httprobe@latest
        if ! [ -x "$(command -v httprobe)" ]; then
            cd dist/
            wget https://github.com/tomnomnom/httprobe/releases/download/v0.2/httprobe-linux-amd64-0.2.tgz
            tar -xzvf httprobe-linux-amd64-0.2.tgz
            sudo mv httprobe /usr/local/bin
            sudo chmod +x /usr/local/bin/httprobe
            #Cleanup
            rm httprobe-linux-amd64-0.2.tgz
            cd ..
        fi
    fi
    
    # Check if interlace is installed
    if ! [ -x "$(command -v interlace)" ]; then
        echo -e "\033[32m"
        cd dist
        echo "Installing interlace..."
        echo -e "\033[0m"
        git clone https://github.com/codingo/Interlace.git
        cd Interlace;sudo python3 setup.py install
        cd ../../
    fi

    # Check if waybackurls is installed
    if ! [ -x "$(command -v waybackurls)" ]; then
        echo -e "\033[32mInstalling waybackurls....\033[0m"
        go install github.com/tomnomnom/waybackurls@latest
        if ! [ -x "$(command -v waybackurls)" ]; then
            cd dist/
            wget https://github.com/tomnomnom/waybackurls/releases/download/v0.1.0/waybackurls-linux-amd64-0.1.0.tgz
            tar -xzvf waybackurls-linux-amd64-0.1.0.tgz
            sudo mv waybackurls /usr/local/bin
            sudo chmod +x /usr/local/bin/waybackurls
            #Cleanup
            rm waybackurls-linux-amd64-0.1.0.tgz
            cd ..
        fi

    fi

    # Check if gau is installed
    if ! [ -x "$(command -v gau)" ]; then
        echo -e "\033[32mInstalling gau....\033[0m"
        go install github.com/lc/gau/v2/cmd/gau@latest
        if ! [ -x "$(command -v gau)" ]; then
            mkdir dist/gau
            cd dist/gau/
            wget https://github.com/lc/gau/releases/download/v2.1.2/gau_2.1.2_linux_amd64.tar.gz
            tar -xzvf gau_2.1.2_linux_amd64.tar.gz
            sudo cp gau /usr/local/bin
            #Cleanup
            rm gau_2.1.2_linux_amd64.tar.gz
            cd ../../
        fi
    fi

    # Check if gospider is installed
    if ! [ -x "$(command -v gospider)" ]; then
        echo -e "\033[32mInstalling gospider....\033[0m"
        go install github.com/jaeles-project/gospider@latest
        if ! [ -x "$(command -v gospider)" ]; then
            cd dist/
            wget https://github.com/jaeles-project/gospider/releases/download/v1.1.6/gospider_v1.1.6_linux_x86_64.zip
            unzip gospider_v1.1.6_linux_x86_64.zip
            sudo mv gospider_v1.1.6_linux_x86_64/gospider /usr/local/bin
            #Cleanup
            rm gospider_v1.1.6_linux_x86_64.zip
            cd ..
        fi
    fi

    # Check if paramspider is installed
    if ! [ -x "$(command -v paramspider)" ]; then
        echo -e "\033[32mInstalling ParamSpider...\033[0m"
        cd dist/
        git clone https://github.com/devanshbatham/ParamSpider
        cd ParamSpider
        pip3 install -r requirements.txt
        mv paramspider.py paramspider
        sudo ln -s $PWD/paramspider /usr/local/bin
        cd ../../
    fi

    # Check if whatweb is installed
    if ! [ -x "$(command -v whatweb)" ]; then
        sudo apt install whatweb
        echo -e "\033[32mInstalling whatweb....\033[0m"
    fi

    # Check if gowitness is installed
    if ! [ -x "$(command -v gowitness)" ]; then
        echo -e "\033[32mInstalling gowitness....\033[0m"
        go install github.com/sensepost/gowitness@latest
        if ! [ -x "$(command -v gowitness)" ]; then
            cd dist/
            wget https://github.com/sensepost/gowitness/releases/download/2.4.2/gowitness-2.4.2-linux-amd64
            sudo mv gowitness-2.4.2-linux-amd64 /usr/local/bin/gowitness
            sudo chmod +x /usr/local/bin/gowitness
            #Cleanup
            cd ..
        fi
        https://github.com/sensepost/gowitness/releases/download/2.4.2/gowitness-2.4.2-linux-amd64
    
    fi

    # Check if gf is installed
    if ! [ -x "$(command -v gf)" ]; then
        echo -e "\033[32mInstalling gf...."
        go install github.com/tomnomnom/gf@latest
        if ! [ -x "$(command -v gf)" ]; then
            cd dist/
            git clone https://github.com/tomnomnom/gf
            cd gf/
            go build main.go
            sudo cp main /usr/local/bin/gf
            #Cleanup
            cd ../../
        fi
        echo "Configuring gf patterns"
        mkdir ~/.gf
        cd dist
        git clone https://github.com/1ndianl33t/Gf-Patterns
        sudo cp Gf-Patterns/*.json ~/.gf/
        cd ..
        echo -e "\033[32m"
        echo "Perform the following to enable bash auto completion with gf."
        echo "-------------------------------------------------------------------------------------------"
        if [ "$RC" == ".bashrc" ]; then
            echo "echo \"complete -W \\\"\\\\\\\$(gf -list)\\\" gf\" >> ~/${RC}"
        else
            echo "echo 'compdef _gf gf

function _gf {
    _arguments \"1: :(\\\$(gf -list))\"
}' >> ~/${RC}"
            echo ""
        fi

        echo "source ~/${RC}"
        echo "-------------------------------------------------------------------------------------------"
	
    fi
 
    echo -e "\033[32mSetup Complete!\033[0m"

elif [ "$option" == "enum" ]; then
    if [ $# -lt 1 ]; then
        echo -e "\033[32m"
        echo "Usage: $0 enum output_directory"
        echo "      Domains             (Required)  - file containing valid domain names. Also accepts a file containing webhosts"
        echo "      output_directory    (Required) -  directory name that will be created for all output files to be stored"
      exit 1
    fi

    #make sure interlace is installed
    if ! [ -x "$(command -v interlace)" ]; then
      echo -e "\033[31mError: Interlace is required for this script.\033[32m" >&2
      exit 1
    fi

    # Check if file exists
    if [ ! -f "$1" ]; then
      echo -e "\033[31mError: File does not exist.\033[32m" >&2
      exit 1
    fi

    if [ ! -e "$2" ]; then
        mkdir $2
    else 
        echo -e "\033[31mError: The specified directory already exists....\033[32m" >&2 
        
    fi
	
    # Check if $1 contains a list of websites or domain names
    if grep -E '^https?://' "$1" > /dev/null; then
      cp $1 $2/webhosts.txt
    else 
      # Check for web applications on default HTTP and HTTPS ports, and additional ports
      echo -e "\033[32mRunning httprobe on all domains....\033[0m"
      cat $1 | httprobe -c 50 -p http:8080 -p http:8000 -p https:8443 -p https:9443 -p http:8001 -p http:81 --prefer-https | tee $2/webhosts.txt
    fi
    echo -e "\033[32mWeb application services found on the following domains and ports:\033[0m"
    cat $2/webhosts.txt

    # Check if webhosts.txt is empty
    if [ -s $2/webhosts.txt ]
    then
        #gowitness file -f $2/webhosts.txt
        interlace -tL $2/webhosts.txt -threads 5 -c "mkdir -p ${2}/_cleantarget_"

        # User WaybackUrls to grab historical data
        if [ -x "$(command -v waybackurls)" ]; then
            interlace -tL $2/webhosts.txt -threads 5 -c "[ -f $2/_cleantarget_/wayback_urls.txt ]  && echo \"File already exists\" || waybackurls _cleantarget_ > $2/_cleantarget_/wayback_urls.txt"
            echo "skipping"
        else
            echo -e "\033[31mError: Waybackurls not installed.....skipping\033[0m"
        fi

        if [ -x "$(command -v gau)" ]; then
            interlace -tL $2/webhosts.txt -threads 5 -c "[ -f $2/_cleantarget_/gau_output.txt ]  && echo \"File already exists2\" || gau _cleantarget_ > $2/_cleantarget_/gau_output.txt"
            echo "skipping"
        else
            echo -e "\033[31mError: Gau not installed.....skipping\033[0m"
        fi

        #if [ -x "$(command -v gospider)" ]; then
         #   interlace -tL $2/webhosts.txt -threads 5 -c "gospider -s _target_ > $2/_cleantarget_/gospider_all.txt"
         #   interlace -tL $2/webhosts.txt -threads 5 -c "cat $2/_cleantarget_/gospider_all.txt  | grep url | grep 200 | cut -d "-" -f 4 | grep _target_ | sort -u > $2/_cleantarget_/gospider_urls.txt"

        #else 
         #   echo -e "\033[31mError: Gospider not installed.....skipping\033[0m"
        #fi

        if [ -x "$(command -v paramspider)" ]; then
            interlace -tL $2/webhosts.txt -threads 5 -c "paramspider -d _cleantarget_ -o $2/_cleantarget_/paramspider.txt"
            echo "test"

        else 
            echo -e "\033[31mError: ParamSpider not installed.....skipping\033[0m"
            echo "test"
        fi

        #if [ -x "$(command -v whatweb)" ]; then
        #    interlace -tL $2/webhosts.txt -threads 5 -c "whatweb _target_ > $2/_cleantarget_/whatweb_output.txt"
         #   echo "test"

        #else
         #   echo -e "\033[31mError: whatweb not installed.....skipping\033[0m"
        #fi

        while read host; do
            domain=$(echo $host | awk -F/ '{print $3}')
            if [ -d $2/$domain ]; then
                mkdir $2/$domain/TargetParams
                #cat "$2/$domain/wayback_urls.txt" "$2/$domain/gau_output.txt" "$2/$domain/gospider_urls.txt" "$2/$domain/paramspider_output.txt" > "$2/$domain/combined_output.txt"
                cat "$2/$domain/wayback_urls.txt" "$2/$domain/gau_output.txt" "$2/$domain/paramspider_output.txt" > "$2/$domain/combined_output.txt"
                gf xss < "$2/$domain/combined_output.txt" > "$2/$domain/TargetParams/gf_xss.txt"
                gf idor < "$2/$domain/combined_output.txt" > "$2/$domain/TargetParams/gf_idor.txt"
                gf ssrf < "$2/$domain/combined_output.txt" > "$2/$domain/TargetParams/gf_ssrf.txt"
                gf sqli < "$2/$domain/combined_output.txt" > "$2/$domain/TargetParams/gf_sqli.txt"
                gf lfi < "$2/$domain/combined_output.txt" > "$2/$domain/TargetParams/gf_lfi.txt"
            fi
        done < $2/webhosts.txt

    else
        echo -e "\033[31mError: Webhosts.txt is empty. No need to run waybackurls, gau, gospider, paramspider, whatweb, aquatone and gf\033[32m" >&2
    fi
        echo -e "\033[32mWeb application enumeration completed. Results can be found in $2\033[0m"

else
    echo "Usage: $0 option [arguments]"
    echo "Options: setup, enum"
    echo "     setup - Setup the environment (To include go, gospider, paramspider, waybackurls, gau, gf, etc...)"
    echo "     enum - Perform web application enumeration" 
    exit 1
fi
