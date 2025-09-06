#!/bin/bash

DEPLOY_PATH=$1

cd $DEPLOY_PATH

# Read template
template=$(cat multi-project-template.html)

# Generate projects content
projects_content=""

# Find all project directories
for project_dir in */; do
    if [ -d "$project_dir" ] && [ "$project_dir" != "logs/" ]; then
        project_name=$(basename "$project_dir")
        
        # Skip if not a project directory (has build folders or latest)
        if [ -d "$project_dir/latest" ] || [ -n "$(ls -1 "$project_dir"/build-* 2>/dev/null)" ]; then
            
            projects_content="$projects_content                    <tr>\n"
            
            # Project name column with link to project dashboard
            projects_content="$projects_content                        <td>\n"
            projects_content="$projects_content                            <a href=\"$project_dir/index.html\" class=\"project-link\">\n"
            projects_content="$projects_content                                <span class=\"project-name\"> $project_name</span>\n"
            projects_content="$projects_content                            </a>\n"
            projects_content="$projects_content                        </td>\n"
            
            # Latest report column
            projects_content="$projects_content                        <td>\n"
            if [ -d "$project_dir/latest" ]; then
                projects_content="$projects_content                            <a href=\"$project_dir/latest/index.html\" class=\"latest-link\">\n"
                projects_content="$projects_content                                 View Latest\n"
                projects_content="$projects_content                            </a>\n"
            else
                projects_content="$projects_content                            <span class=\"historical-count\">No latest report</span>\n"
            fi
            projects_content="$projects_content                        </td>\n"
            
            # Historical reports column
            projects_content="$projects_content                        <td>\n"
            
            # Count historical builds
            historical_count=$(ls -1d "$project_dir"/build-* 2>/dev/null | wc -l)
            if [ "$historical_count" -gt 0 ]; then
                projects_content="$projects_content                            <a href=\"$project_dir\" class=\"project-link\">\n"
                projects_content="$projects_content                                <span class=\"historical-count\"> $historical_count reports</span>\n"
                projects_content="$projects_content                            </a>\n"
            else
                projects_content="$projects_content                            <span class=\"historical-count\">No historical reports</span>\n"
            fi
            
            projects_content="$projects_content                        </td>\n"
            projects_content="$projects_content                    </tr>\n"
        fi
    fi
done

if [ -z "$projects_content" ]; then
    projects_content="                    <tr>\n                        <td colspan=\"3\" style=\"text-align: center; padding: 40px; color: #6c757d;\">\n                            📋 No projects found<br>\n                            <small>Deploy some test reports to see projects</small>\n                        </td>\n                    </tr>"
fi

# Replace placeholder
echo "$template" | sed "s|{{PROJECTS_CONTENT}}|$projects_content|g" > index.html