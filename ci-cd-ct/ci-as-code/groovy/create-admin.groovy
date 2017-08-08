#!groovy

import jenkins.model.*
import hudson.security.*

def env = System.getenv()
def jenkins = Jenkins.getInstance()

  
println "--> creating user"

jenkins.setSecurityRealm(new HudsonPrivateSecurityRealm(false))
jenkins.setAuthorizationStrategy(new GlobalMatrixAuthorizationStrategy())

def user = jenkins.getSecurityRealm().createAccount(env['JENKINS_USER'], env['JENKINS_PASSWORD'])
user.save()

jenkins.getAuthorizationStrategy().add(Jenkins.ADMINISTER, env['JENKINS_USER'])
jenkins.save()
