# Kubernetes OpenID Connect User Integration

Kubernetes supports user authentication with [OpenID Connect ID Tokens](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#openid-connect-tokens).\
This enables various use cases, where you restrict team Kubernetes permissions by user type:

- Locking down access to the `kubectl` tool.
- Locking down access to the [Kubernetes Dashboard](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/).

## Tokens and User Permissions

Kubernetes user level access typically represents employees that you organize into groups.\
Each group can be assigned restricted Kubernetes permissions using role based access control.

Your authorization server can issue ID tokens that Kubernetes treats as user assertions to authenticate users.\
Kubernetes allows you to map an ID token claim like `employee_groups` to a Kubernetes role:

```json
{
  "sub": "john.doe",
  "iss": "https://login.example.com",
  "aud": "kubernetes-client",
  "employee_groups": ["engineers"],
  "iat": 1736616585042,
  "exp": 1737516615.042
}
```

## Kubernetes Token Validation

The Kubernetes API server requires calls these authorization server endpoints to validate ID tokens:

- An OpenID Connect discovery endpoint that uses TLS.
- A JWKS URI with the token signing public keys.

## Productive Integrations

When getting integrated it can be useful to:

- Implement the integration work on a development cluster.
- Quickly issue tokens as one or more test users.

To do so you can use the techniques from [Testing Zero Trust APIs](https://curity.io/resources/learn/testing-zero-trust-apis/) and work with a mock authorization server.

## Testing the Flow

This GitHub repo provides a mock authorization server that you can use to get integrated.

### Prerequisites

First ensure that these tools are installed:

- A Docker engine
- Kubernetes in Docker (KIND) running Kubernetes 1.30+
- Node.js 20+
- OpenSSL 3+
- The envsubst tool

### 1. Create a Local Cluster

Create a KIND cluster that includes OpenID Connect authentication configuration:

```bash
./1-create-cluster.sh
```

The default configuration at `~/.kube/config` runs as user `kubernetes-admin` with access to all resources:

```bash
kubectl get pod -A
```

### 2. Prepare External Load Balancers

Run the load balancer provider to enable external networking connectivity:

```bash
./2-run-load-balancer-provider.sh
```

### 3. Deploy the API Gateway

Deploy an API gateway to enable external HTTPS URLs that the Kubernetes API server requires:

```bash
./3-deploy-api-gateway.sh
```

Add the reported external IP address to the host computer's `/etc/hosts` file similar to the following:

```bash
172.30.0.4 login.test.example dashboard.test.example
```

### 4. Deploy the Mock Authorization Server

Build and deploy the mock authorization server as a Docker container.\
If required, run the authorization server locally to understand its code and operations.

```bash
./4-deploy-authorization-server.sh
```

Then call external URLs:

```bash
export CURL_CA_BUNDLE=resources/external-certificates/external-ca.crt
curl https://login.test.example/.well-known/openid-configuration
curl https://login.test.example/jwks
```

Then connect to the a utility pod that can act as an OAuth client:

```bash
kubectl -n applications exec -it curl -- sh
```

Also call internal URLs:

```bash
curl http://mockauthorizationserver.identity.svc:8443/.well-known/openid-configuration
curl http://mockauthorizationserver.identity.svc:8443/jwks
```

### 5. Create Restrict Permissions

Run a script to apply role based access control:

```bash
./5-restrict-permissions.sh
```

This introduces the following simple rules:

- DevOps users can manage resources from all namespaces.
- Developer users can only manage resources in the `applications` namespace.

### 6. Get a User Assertion

Whenever required, quickly get a user level ID token for an employee role using one of these commands:

```bash
./6-create-user-assertion.sh 'developer'
./6-create-user-assertion.sh 'devops'
```

### 7. Use Restricted Permissions

Install the Kubernetes dashboard:

```bash
./5-deploy-dashboard.sh
```

Then browse to `https://dashboard.test.example` and paste in a user assertion to authenticate.

```bash
curl -i -k https://dashboard.test.example
```

To run `kubectl` with reduced privileges, save a cluster configuration to file and `export KUBECONFIG` to point to it:

```yaml
apiVersion: v1
kind: Config
current-context: restricted
clusters:
- name: kind-demo
  cluster:
    certificate-authority-data: ...
    server: https://127.0.0.1:38451
users:
- name: john.doe
  user:
    token: ...
contexts:
- name: restricted
  context:
    cluster: kind-demo
    user: john.doe
```

Use the following command to troubleshoot:

```bash
kubectl -n kube-system logs -f kube-apiserver-demo-control-plane
```

### 8. Free Resources

When you have finished testing, free resources with this command:

```bash
./5-delete-cluster.sh
```
