# Playwright Dashboard Templates

This project contains the HTML templates and scripts for generating the Playwright test reports dashboard.

## Files

- `index-template.html` - Main dashboard HTML template
- `generate-index.sh` - Script to generate index page from template
- `Jenkinsfile` - Jenkins pipeline to deploy templates to VPS

## Usage

1. Modify templates as needed
2. Run Jenkins pipeline to deploy to VPS
3. Test reports pipeline will use these templates automatically

## Template Variables

- `{{BUILD_NUMBER}}` - Current build number
- `{{HISTORICAL_REPORTS}}` - Generated HTML for historical reports list