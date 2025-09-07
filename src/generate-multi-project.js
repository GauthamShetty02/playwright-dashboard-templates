#!/usr/bin/env node

const fs = require('fs-extra');
const path = require('path');
const Handlebars = require('handlebars');

async function generateMultiProject(deployPath) {
  try {
    // Read template
    const templatePath = path.join(__dirname, '..', 'multi-project-template.html');
    const template = await fs.readFile(templatePath, 'utf8');
    
    // Change to deploy directory
    process.chdir(deployPath);
    
    // Generate projects content
    const projectsContent = await generateProjectsContent();
    
    // Replace placeholder directly to avoid HTML escaping
    const html = template.replace('{{PROJECTS_CONTENT}}', projectsContent);
    
    // Write output
    await fs.writeFile('index.html', html);
    console.log('Multi-project dashboard generated successfully');
    
  } catch (error) {
    console.error('Error generating multi-project dashboard:', error.message);
    process.exit(1);
  }
}

async function generateProjectsContent() {
  try {
    const dirs = await fs.readdir('.');
    const projectDirs = [];
    
    for (const dir of dirs) {
      if (dir === 'logs') continue;
      
      const stat = await fs.stat(dir);
      if (!stat.isDirectory()) continue;
      
      const hasLatest = await fs.pathExists(path.join(dir, 'latest'));
      const buildDirs = await fs.readdir(dir).then(files => 
        files.filter(f => f.startsWith('build-'))
      ).catch(() => []);
      
      if (hasLatest || buildDirs.length > 0) {
        projectDirs.push({
          name: dir,
          hasLatest,
          historicalCount: buildDirs.length
        });
      }
    }
    
    if (projectDirs.length === 0) {
      return `<tr>
        <td colspan="3" style="text-align: center; padding: 40px; color: #6c757d;">
          📋 No projects found<br>
          <small>Deploy some test reports to see projects</small>
        </td>
      </tr>`;
    }
    
    return projectDirs.map(project => `<tr>
        <td>
          <a href="${project.name}/index.html" class="project-link">
            <span class="project-name">${project.name}</span>
          </a>
        </td>
        <td>
          ${project.hasLatest 
            ? `<a href="${project.name}/latest/index.html" class="latest-link">View Latest</a>`
            : `<span class="historical-count">No latest report</span>`
          }
        </td>
        <td>
          ${project.historicalCount > 0
            ? `<a href="${project.name}" class="project-link">
                <span class="historical-count">${project.historicalCount} reports</span>
              </a>`
            : `<span class="historical-count">No historical reports</span>`
          }
        </td>
      </tr>`).join('\n');
    
  } catch (error) {
    return `<tr>
      <td colspan="3" style="text-align: center; padding: 40px; color: #6c757d;">
        📋 Error loading projects<br>
        <small>${error.message}</small>
      </td>
    </tr>`;
  }
}

// CLI usage
if (require.main === module) {
  const [deployPath] = process.argv.slice(2);
  
  if (!deployPath) {
    console.error('Usage: node generate-multi-project.js <DEPLOY_PATH>');
    process.exit(1);
  }
  
  generateMultiProject(deployPath);
}

module.exports = { generateMultiProject };