# Playwright Dashboard Templates

This project contains the HTML templates and Node.js scripts for generating the Playwright test reports dashboard.

## Files

- `index-template.html` - Main dashboard HTML template
- `multi-project-template.html` - Multi-project dashboard template
- `src/generate-index.js` - Node.js script to generate single project dashboard
- `src/generate-multi-project.js` - Node.js script to generate multi-project dashboard
- `generate-index.sh` - Legacy bash script (deprecated)
- `Jenkinsfile` - Jenkins pipeline to deploy templates to VPS

## Usage

1. Install dependencies: `npm install`
2. Modify templates as needed
3. Run Jenkins pipeline to deploy to VPS
4. Test reports pipeline will use these scripts automatically

### Node.js Script Usage
```bash
# Generate single project dashboard
node src/generate-index.js <BUILD_NUMBER> <DEPLOY_PATH> <PROJECT_NAME>

# Generate multi-project dashboard
node src/generate-multi-project.js <DEPLOY_PATH>
```

### Legacy Bash Script Usage (Deprecated)
```bash
./generate-index.sh <BUILD_NUMBER> <DEPLOY_PATH> <PROJECT_NAME>
```

## Template Variables

- `{{BUILD_NUMBER}}` - Current build number
- `{{PROJECT_NAME}}` - Project identifier for unique paths
- `{{HISTORICAL_REPORTS}}` - Generated HTML for historical reports list