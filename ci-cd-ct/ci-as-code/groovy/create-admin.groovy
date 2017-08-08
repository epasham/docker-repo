#!groovy

import jenkins.model.*
import hudson.security.*
import jenkins.install.*;

def env = System.getenv()
def instance = Jenkins.getInstance()

  
println "--> creating user"

def hudsonRealm = new HudsonPrivateSecurityRealm(false)
def strategy = new FullControlOnceLoggedInAuthorizationStrategy()

hudsonRealm.createAccount(env['JENKINS_USER'],env['JENKINS_PASSWORD'])
instance.setSecurityRealm(hudsonRealm)
instance.setAuthorizationStrategy(strategy)
instance.save()
