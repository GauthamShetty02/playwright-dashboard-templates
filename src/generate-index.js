#!/usr/bin/env node

const fs = require('fs-extra');
const path = require('path');
const Handlebars = require('handlebars');

async function generateIndex(buildNumber, deployPath, projectName) {
  try {
    // Read template
    const templatePath = path.join(__dirname, '..', 'index-template.html');
    const template = await fs.readFile(templatePath, 'utf8');
    
    // Change to deploy directory
    process.chdir(deployPath);
    
    // Generate historical reports
    const historicalReports = await generateHistoricalReports(buildNumber);
    
    // Compile template
    const compiledTemplate = Handlebars.compile(template);
    const html = compiledTemplate({
      BUILD_NUMBER: buildNumber,
      PROJECT_NAME: projectName,
      HISTORICAL_REPORTS: historicalReports
    });
    
    // Write output
    await fs.writeFile('index.html', html);
    console.log('Dashboard generated successfully');
    
  } catch (error) {
    console.error('Error generating dashboard:', error.message);
    process.exit(1);
  }
}

async function generateHistoricalReports(currentBuild) {
  try {
    const dirs = await fs.readdir('.');
    const buildDirs = dirs
      .filter(dir => dir.startsWith('build-') && !dir.includes(`-${currentBuild}-`))
      .sort((a, b) => b.localeCompare(a)); // Sort newest first
    
    if (buildDirs.length === 0) {
      return `<div class="no-reports">
        📋 No historical reports yet<br>
        <small>Run more tests to see build history</small>
      </div>`;
    }
    
    return buildDirs.map(dir => {
      const parts = dir.split('-');
      const buildNum = parts[1];
      const timestamp = parts.slice(2).join('-').replace(/_/g, ' ').replace(/-/g, '/');
      
      return `<a href="${dir}/index.html" class="report-link historical-link">
        📈 Build ${buildNum}
        <div class="timestamp">${timestamp}</div>
      </a>`;
    }).join('\n');
    
  } catch (error) {
    return `<div class="no-reports">
      📋 No historical reports yet<br>
      <small>Run more tests to see build history</small>
    </div>`;
  }
}

// CLI usage
if (require.main === module) {
  const [buildNumber, deployPath, projectName] = process.argv.slice(2);
  
  if (!buildNumber || !deployPath || !projectName) {
    console.error('Usage: node generate-index.js <BUILD_NUMBER> <DEPLOY_PATH> <PROJECT_NAME>');
    process.exit(1);
  }
  
  generateIndex(buildNumber, deployPath, projectName);
}

module.exports = { generateIndex };