#!/bin/bash

DEPLOY_PATH=$1

cd $DEPLOY_PATH

# Read template from dashboard-generator directory
if [ -f "dashboard-generator/multi-project-template.html" ]; then
    template=$(cat dashboard-generator/multi-project-template.html)
else
    template=$(cat multi-project-template.html)
fi

# Generate projects content
projects_content=""

# Find all project directories
for project_dir in */; do
    if [ -d "$project_dir" ] && [ "$project_dir" != "logs/" ]; then
        project_name=$(basename "$project_dir")
        
        # Skip if not a project directory (has build folders or latest)
        if [ -d "$project_dir/latest" ] || [ -n "$(ls -1 "$project_dir"/build-* 2>/dev/null)" ]; then
            
            projects_content="$projects_content<tr><td><a href=\"$project_dir/index.html\" class=\"project-link\"><span class=\"project-name\">$project_name</span></a></td><td>"
            
            if [ -d "$project_dir/latest" ]; then
                projects_content="$projects_content<a href=\"$project_dir/latest/index.html\" class=\"latest-link\">View Latest</a>"
            else
                projects_content="$projects_content<span class=\"historical-count\">No latest report</span>"
            fi
            
            projects_content="$projects_content</td><td>"
            
            # Count historical builds
            historical_count=$(ls -1d "$project_dir"/build-* 2>/dev/null | wc -l)
            if [ "$historical_count" -gt 0 ]; then
                projects_content="$projects_content<a href=\"$project_dir\" class=\"project-link\"><span class=\"historical-count\">$historical_count reports</span></a>"
            else
                projects_content="$projects_content<span class=\"historical-count\">No historical reports</span>"
            fi
            
            projects_content="$projects_content</td></tr>"
        fi
    fi
done

if [ -z "$projects_content" ]; then
    projects_content="<tr><td colspan=\"3\" style=\"text-align: center; padding: 40px; color: #6c757d;\">No projects found<br><small>Deploy some test reports to see projects</small></td></tr>"
fi

# Replace placeholder
echo "$template" | sed "s|{{PROJECTS_CONTENT}}|$projects_content|g" > index.html