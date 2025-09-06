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
            
            projects_content="$projects_content            <div class=\"project-section\">\n"
            projects_content="$projects_content                <div class=\"project-header\">📁 $project_name</div>\n"
            projects_content="$projects_content                <div class=\"project-content\">\n"
            
            # Latest report section
            if [ -d "$project_dir/latest" ]; then
                projects_content="$projects_content                    <div class=\"latest-section\">\n"
                projects_content="$projects_content                        <h3 class=\"section-title\">📊 Latest Report</h3>\n"
                projects_content="$projects_content                        <a href=\"$project_dir/latest/index.html\" class=\"report-link latest\">\n"
                projects_content="$projects_content                            🚀 Latest Test Results\n"
                projects_content="$projects_content                            <span class=\"badge\">CURRENT</span>\n"
                projects_content="$projects_content                            <div class=\"timestamp\">Click to view detailed results</div>\n"
                projects_content="$projects_content                        </a>\n"
                projects_content="$projects_content                    </div>\n"
            fi
            
            # Historical reports section
            projects_content="$projects_content                    <div class=\"historical-section\">\n"
            projects_content="$projects_content                        <h3 class=\"section-title\">📈 Historical Reports</h3>\n"
            
            # List historical builds
            historical_found=false
            for build_dir in $(ls -1t "$project_dir" | grep "^build-" 2>/dev/null || echo ""); do
                if [ -d "$project_dir/$build_dir" ]; then
                    historical_found=true
                    build_num=$(echo $build_dir | cut -d'-' -f2)
                    timestamp=$(echo $build_dir | cut -d'-' -f3- | tr '_' ' ' | tr '-' '/')
                    projects_content="$projects_content                        <a href=\"$project_dir/$build_dir/index.html\" class=\"report-link historical-link\">\n"
                    projects_content="$projects_content                            📈 Build $build_num\n"
                    projects_content="$projects_content                            <div class=\"timestamp\">$timestamp</div>\n"
                    projects_content="$projects_content                        </a>\n"
                fi
            done
            
            if [ "$historical_found" = false ]; then
                projects_content="$projects_content                        <div class=\"no-reports\">\n"
                projects_content="$projects_content                            📋 No historical reports yet<br>\n"
                projects_content="$projects_content                            <small>Run more tests to see build history</small>\n"
                projects_content="$projects_content                        </div>\n"
            fi
            
            projects_content="$projects_content                    </div>\n"
            projects_content="$projects_content                </div>\n"
            projects_content="$projects_content            </div>\n\n"
        fi
    fi
done

if [ -z "$projects_content" ]; then
    projects_content="            <div class=\"no-reports\">\n                📋 No projects found<br>\n                <small>Deploy some test reports to see projects</small>\n            </div>"
fi

# Replace placeholder
echo "$template" | sed "s|{{PROJECTS_CONTENT}}|$projects_content|g" > index.html