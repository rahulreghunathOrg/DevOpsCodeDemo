FROM tomcat:9
COPY target/addressbook.war /usr/local/tomcat/webapps/addressbook.war
CMD ["catalina.sh", "run"]
EXPOSE 8080

