## Getting Started

---

### Windows prerequisites
If you are on windows, you first need to install WSL (windows subsystem linux).\
We have written a simple [powershell script](./windows_prerequisites.ps1) for this.\
Open a new powershell terminal **with admin privileges** in this directory / repository folder.\
Then run the following command and follow the instructions.\
You might need to reboot your computer before opening WSL2 / Ubuntu.\
When opening for the first time, you will need to choose a username and password, after which your setup should look similar to [this picture](./initialUbuntuSetup.png)

```bash
PowerShell -ExecutionPolicy Bypass -File .\windows_prerequisites.ps1
```

Now that Ubuntu / WSL2 is installed, you will need to copy the whole repository folder over to the WSL2 filesystem (otherwise, the disk IO performance will be horrible).\
You can do this either by using the Windows explorer or in the command line in WSL2.

1. Windows explorer: In the left overview of all folders and drives there should be a new filesystem called Linux (also check in the network tab).\
Open the Linux drive and open the folder named "home", followed by your username.\
Copy the whole repository folder from your current location to the Linux folder /home/your-username (note that the folder will initially be empty).\
Finally, delete the folder from your current location such that you only have the folder inside the Linux filesystem.

2. Using the terminal: Open a new Ubuntu / WSL2 terminal window.\
This will automatically open your home folder of the Linux file system.\
You then need to locate where the repository / folder that you have downloaded resides.\
You can use the ```cp -ar``` command to copy the folder from the Windows drive to the Linux filesystem.\
The command takes the following arguments: cp **source_file** _target_file_\
Thus we need to specify **source_file** the folder we want to copy from Windows filesystem and the _target_file_ where to copy the folder to in the Linux filesystem.\
As visible in [this screenshot](./copyFolderToUbuntu.png), the repository folder resides under the C drive in /mnt/c/\
If your file is not on your C drive, the folder path will be something like /mnt/d/\
In the screenshot, the downloaded repository folder is in the Downloads folder of the current user on the C drive, thus the path for **source_file** is ```/mnt/c/Users/immol/Downloads```\
The terminal in [the screenshot](./copyFolderToUbuntu.png) is currently in the home directory, indicated by ~ in the path in blue.\
As we want to copy the folder to the home folder (/home/your-username) we can specify the current directory (.) as the _target_file_, thus the dot at the end of the command.\
If you happen to not be in the home folder, you can also run the command with explicitly copying to the home folder as such:
```bash
cp -ar /mnt/c/your-path /home/your-username
```
Else you can run
```bash
cp -ar /mnt/c/your-path .
```
with . indicating to copy to the current path (in this case your home folder).\
You can check if the repository was successfully copied over using ```ls``` to list folders and files, as visible in [the screenshot](./copyFolderToUbuntu.png).\
You can then delete the downloaded folder / repository from the Windows filesystem in the explorer.

---

### Installation
To install all required software to run this repository, open a new terminal (windows users need to open a Ubuntu terminal from WSL2) in this directory / repository folder.\
For installation, we have written a shell script that will, according to the system you are using, install everything you need.\
To run the shell script, run the following command and follow the instructions.\
See [this example](./runningScript.png) if you are confused.

```bash
source universal_setup.sh
```

This can take a few minutes.
If you encounter any issues, please close the window / shell and open a new one and try to run the command again.

---

### Running the app after successful installation
```bash
npm run dev
# or
yarn dev
# or
deno task dev
```

Open [http://localhost:3000](http://localhost:3000) with your browser to see the
result.

You can start editing the page by modifying `app/page.tsx`. The page
auto-updates as you edit the file.

This project uses
[`next/font`](https://nextjs.org/docs/app/building-your-application/optimizing/fonts)
to automatically optimize and load [Geist](https://vercel.com/font), a new font
family for Vercel.

## Learn More

To learn more about Next.js, take a look at the following resources:

- [Next.js Documentation](https://nextjs.org/docs) - learn about Next.js
  features and API.
- [Learn Next.js](https://nextjs.org/learn) - an interactive Next.js tutorial.

You can check out
[the Next.js GitHub repository](https://github.com/vercel/next.js) - your
feedback and contributions are welcome!

## Deploy on Vercel

The easiest way to deploy your Next.js app is to use the
[Vercel Platform](https://vercel.com/new?utm_medium=default-template&filter=next.js&utm_source=create-next-app&utm_campaign=create-next-app-readme)
from the creators of Next.js.

Check out our
[Next.js deployment documentation](https://nextjs.org/docs/app/building-your-application/deploying)
for more details.
