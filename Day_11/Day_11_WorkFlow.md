## Day 11 : Tomcat deployment

#### Requirements:
	Requirement					Expected result
	===========					================
	App Server					stapp01
	Java application server		Tomcat
	Tomcat port					6400
	WAR source					Jump host /tmp/ROOT.war
	WAR deployment				Tomcat webapps/ROOT.war
	URL							http://stapp01:6400
	Final test					curl http://stapp01:6400




#### Workflow
```
		Jump Host
			|
			| SSH
			v
		App Server 1 (stapp01)
			|
			| Tomcat
			| TCP 6400
			v
		ROOT.war
			|
			v
		http://stapp01:6400/

```