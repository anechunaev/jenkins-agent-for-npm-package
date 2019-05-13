# jenkins-agent-for-npm-package
Jenkins agent for building, testing and publishing NPM packages

## Pipeline example

```
import groovy.json.JsonSlurper

pipeline {
	environment { 
		CI = 'true'
		NPM_TOKEN = credentials('npm-token')
	}
	agent {
		docker {
			image "bungubot/jenkins-agent-for-npm-package:latest"
			args "-e NPM_TOKEN=${env.NPM_TOKEN}"
		}
	}
	stages {
		stage('Setup') {
			steps {
				sh 'npm install'
			}
		}
		stage('Build') {
			steps {
				sh 'npm run build'
			}
		}
		stage('Test') {
			steps {
				sh 'npm test'
			}
		}
		stage('Publish') {
			when {
				buildingTag()
			}
			steps {
				script {
					def id = getTag('package.json')

					if (id) {
						sh "npm publish --tag=${id}"
					} else {
						sh "npm publish"
					}
				}
			}
		}
	}
}

def getTag(jsonFile){
	def fileContent = readFile "${jsonFile}"
	Map jsonContent = (Map) new JsonSlurper().parseText(fileContent)
	def (version, tag) = jsonContent['version'].tokenize('-')
	def id

	if (tag) {
		def (preid, prebuild) = tag.tokenize('.')
		id = preid
	}

	return id
}

```