Domain Finder Tool

Overview
The Domain Finder Tool is a command-line script developed by Aswanth to discover subdomains for a given domain. It uses assetfinder to find subdomains and httprobe to verify which subdomains are reachable, providing a sorted list of active subdomains.

Features
Finds subdomains using assetfinder
Checks reachability of subdomains with httprobe
Presents a sorted list of active subdomains
Allows users to visit subdomains directly from the command line
Prerequisites
Before using this tool, make sure you have the following installed:

assetfinder: Used to find subdomains. Install it from GitHub - assetfinder.
httprobe: Used to check which subdomains are reachable. Install it from GitHub - httprobe.
Usage
Clone the repository:

bash
Copy code
git clone https://github.com/Aswanthkp333/Domain-Finder.git
cd Domain-Finder
Install assetfinder and httprobe (if not already installed):

bash
Copy code
# Install assetfinder
go get -u github.com/tomnomnom/assetfinder

# Install httprobe
go get -u github.com/tomnomnom/httprobe
Run the Domain Finder script:

bash
Copy code
bash domain_finder.sh
Follow the prompts:

Enter the domain name when prompted.
Confirm the domain name to proceed.
Choose a subdomain to visit from the list (if applicable).
Optionally, enter another domain to continue.
Enjoy using Domain Finder to manage and explore subdomains efficiently!

About
Developed by Aswanth. For more tools and updates, visit GitHub - Aswanth333.
