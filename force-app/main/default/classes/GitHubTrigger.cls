public with sharing class GitHubTrigger {
    @future(callout=true)
    public static void triggerWorkflow() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:GitHub/repos/CloudOps-Hub/VisualPath_CICD/actions/workflows/post-deployment.yml/dispatches');
        req.setMethod('POST');
        req.setHeader('Accept', 'application/vnd.github+json');
        req.setHeader('X-GitHub-Api-Version', '2022-11-28');
        req.setHeader('Content-Type', 'application/json');
        req.setBody('{"ref":"main"}');

        Http http = new Http();
        HttpResponse res = http.send(req);
        System.debug('Status: ' + res.getStatusCode());
        System.debug('Body: ' + res.getBody());
        
        Http http2 = new Http();
        HttpResponse res2 = http2.send(req);
        System.debug('Status: ' + res2.getStatusCode());
        System.debug('Body: ' + res2.getBody());
    }
}