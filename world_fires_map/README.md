# Fire Information for Resource Management System (FIRMS) for Home Assistant

This repository contains a Home Assistant Add-on designed to integrate data from NASA's **Fire Information for Resource Management System (FIRMS)** into your local smart home environment.

## About this Add-on
This add-on retrieves near real-time fire data from NASA's FIRMS API. It allows you to monitor fire activity in your specified region directly within Home Assistant, enabling you to create automations or dashboards based on wildfire proximity or local fire incidents.

*Note: This add-on was originally created for my personal use to keep track of fire hazards in my coastal region, but it is now available for the community to use.*

## Built with AI
As a QA professional, I am not a developer by trade. A significant portion of the logic, structure, and code within this add-on was crafted with the **assistance of AI**. This has allowed me to turn my ideas into functional solutions faster and more efficiently.

## Disclaimer
* **Use at your own risk:** This add-on is primarily for private use and may lack the extensive testing found in official integrations. 
* **Data Accuracy:** Fire data is provided by NASA's FIRMS. Please ensure you comply with their [Terms of Service](https://earthdata.nasa.gov/earth-observation-data/near-real-time/firms). This add-on is not officially affiliated with or endorsed by NASA.
* **Support:** As this is a personal project, I cannot provide extensive support. If you encounter issues, feel free to open a GitHub issue, and I will do my best to address it when time permits.

## Installation
To use this add-on, add this repository to your Home Assistant Add-on Store:

1. Go to **Settings** -> **Add-ons**.
2. Click the **three-dot menu** in the top right corner and select **Repositories**.
3. Add the repository URL: `https://github.com/Donzaffi/Home-Assistant-Addons` (the main repository).
4. Click **Add** and then **Close**.

## Requirements
* A valid [NASA FIRMS API key](https://firms.modaps.eosdis.nasa.gov/).
* Your geographical coordinates configured in the add-on settings.

---
*Created by Donzaffi*
