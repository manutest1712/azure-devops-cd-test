# Overview

This project provides a cloud-hosted Flask web application that predicts housing prices using a trained machine-learning model.  
Users can send property details to the `/predict` API and instantly receive price predictions in JSON format.  
Automation is built in: a Makefile simplifies setup, testing, and deployment.
Continuous Integration runs through GitHub Actions, which installs dependencies, runs pylint for code analysis and pytest to execute unit test cases on every push to the main branch.
Azure Pipelines provides continuous delivery by packaging the application and deploying it directly to an Azure Web App.  
The result is a reliable, scalable, and automated solution that supports rapid development and real-time model inference.

## Project Plan

[Trello board for the Housing Trend Project Planner](https://trello.com/b/9a9XvYIE/fask-housing-trend-weekly-plan)

[Project Plan In Excel](https://docs.google.com/spreadsheets/d/1QsJpxNEZldNpzWKBwi_6Fmf42sGRiEYL/edit?usp=sharing&ouid=109875377807326084890&rtpof=true&sd=true)

## Instructions

### Install the Terraform Azure DevOps Extension
1. Navigate to your Azure DevOps organization settings
2. Go to "Extensions" and then "Browse marketplace."
3. Search for "Terraform" and locate the extension published by Microsoft DevLabs (or a suitable alternative if preferred)
4. Install the extension into your Azure DevOps organization. This makes Terraform tasks available for use in your pipelines.                                                                              


