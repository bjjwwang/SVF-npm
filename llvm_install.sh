#!/bin/bash
SVFHOME=$(pwd)
sysOS=`uname -s`
MajorLLVMVer=16
LLVMVer=${MajorLLVMVer}.0.0
UbuntuLLVM_RTTI="https://github.com/SVF-tools/SVF/releases/download/SVF-3.0/llvm-${LLVMVer}-ubuntu24-rtti-amd64.tar.gz"
UbuntuZ3="https://github.com/Z3Prover/z3/releases/download/z3-4.8.8/z3-4.8.8-x64-ubuntu-16.04.zip"
UbuntuLLVM_RTTI="https://github.com/SVF-tools/SVF/releases/download/SVF-3.0/llvm-${MajorLLVMVer}.0.0-ubuntu24-rtti-amd64.tar.gz"
Z3Home="z3.obj"
LLVMHome="llvm-${LLVMVer}.obj"

# resume softlink libSvfLLVM.so since npm pack would ignore softlink
ln -sf libSvfLLVM.so.16 "$SVFHOME/SVF-linux/Release-build/lib/libSvfLLVM.so"

cd $SVFHOME
cd ..
install_path=$(pwd)

function check_and_install_brew {
    if command -v brew >/dev/null 2>&1; then
        echo "Homebrew is already installed."
    else
        echo "Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        if [ $? -eq 0 ]; then
            echo "Homebrew installation completed."
        else
            echo "Homebrew installation failed."
            exit 1
        fi
    fi
}

########
# Download LLVM binary
########
if [[ $sysOS == "Darwin" ]]
then
       check_and_install_brew
       echo "Installing LLVM binary"
       brew install llvm@${MajorLLVMVer}
       # check whether llvm is installed
       if [ $? -eq 0 ]; then
              echo "LLVM binary installation completed."
       else
              echo "LLVM binary installation failed."
              exit 1
       fi
       mkdir -p $install_path/$LLVMHome
       ln -s $(brew --prefix llvm@${MajorLLVMVer})/* $install_path/$LLVMHome
elif [[ $sysOS == "Linux" ]]
then
       if [ ! -d "$install_path/$LLVMHome" ]
       then
       		echo 'Downloading LLVM binary for Ubuntu'
      		wget -c $UbuntuLLVM -O llvm-ubuntu.tar.xz
      		mkdir $install_path/$LLVMHome 
		echo 'Unzipping LLVM binary for Ubuntu'
		tar -xf "llvm-ubuntu.tar.xz" -C $install_path/$LLVMHome --strip-components 1
		rm llvm-ubuntu.tar.xz
       fi
else
	echo 'not support llvm builds in OS other than Ubuntu and Mac'
fi
export LLVM_DIR="$install_path/$LLVMHome"
echo "LLVM_DIR=$LLVM_DIR"
########
# Download z3 binary
########
urlZ3=""
if [[ $sysOS == "Darwin" ]]
then
       if [ ! -d "$install_path/$Z3Home" ]
       then
       		echo 'Downloading z3 binary for MacOS '
	 	brew install z3
   		if [ $? -eq 0 ]; then
		      echo "z3 binary installation completed."
	        else
		      echo "z3 binary installation failed."
		      exit 1
	        fi
      	 	mkdir -p $install_path/$Z3Home
       		ln -s $(brew --prefix z3)/* $install_path/$Z3Home
       fi
elif [[ $sysOS == "Linux" ]]
then
       if [ ! -d "$install_path/$Z3Home" ]
       then
       		echo 'Downloading z3 binary for Ubuntu'
      		wget -c $UbuntuZ3 -O z3.zip
      		mkdir $install_path/$Z3Home 
		echo 'Unzipping z3 binary for Ubuntu'
        unzip -q "z3.zip" && mv ./z3-*/* $install_path/$Z3Home/
		rm z3.zip
       fi
else
	echo 'not support z3 builds in OS other than Ubuntu and Mac'
fi
export Z3_DIR="$install_path/$Z3Home"
echo "Z3_DIR=$Z3_DIR"
export SVF_DIR="$install_path/SVF"
echo "SVF_DIR=$SVF_DIR"

if [[ $sysOS == "Darwin" ]]
then 
ln -s $install_path/svf-lib/SVF-osx $SVF_DIR
echo -e "Build your own project with the following cmake command:\n cmake -DSVF_DIR=$SVF_DIR -DLLVM_DIR=$LLVM_DIR"
elif [[ $sysOS == "Linux" ]]
then 
ln -s $install_path/svf-lib/SVF-linux $SVF_DIR
echo -e "Build your own project with the following cmake command:\n cmake -DSVF_DIR=$SVF_DIR -DLLVM_DIR=$LLVM_DIR"
fi
