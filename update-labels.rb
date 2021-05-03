require "octokit"

# https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token
personal_access_token = "{YOUR_PERSONAL_ACCESS_TOKEN_HERE}"

labels = {
    "bug" => ["E99695", "Something isn't working"],
    "enhancement" => ["C2E0C6", "New feature or request"],
    "task" => ["BFD4F2", "Work to be done"]
}

# Provide authentication credentials
client = Octokit::Client.new(:access_token => personal_access_token)

# List repositories for the authenticated user
repos = client.repositories()
repos.each do |repo|
    # List labels for a repository
    repo_labels = client.labels(repo.full_name)
    repo_labels.each do |repo_label|
        if !labels.include? repo_label.name
            # Delete a label
            client.delete_label!(repo.full_name, repo_label.name)
        end
    end

    labels.each do |label_name, options|
        begin
            repo_label = client.label(repo.full_name, label_name)

            # Update a label
            client.update_label(repo.full_name, label_name, {:color => options[0], :description => options[1]})  
        rescue Octokit::NotFound => exception
            # Create a label
            client.add_label(repo.full_name, label_name, options[0], {:description => options[1]})        
        end
    end
end
