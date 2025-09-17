global class PostCopyClass implements SandboxPostCopy {
    global void runApexClass(SandboxContext context) {
        GitHubTrigger.triggerWorkflow(); // Calls GitHub Action
    }
}