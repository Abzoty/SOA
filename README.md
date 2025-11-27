in each service folder create an environment <code>python -m venv venv</code>
install the requirments in the requirments.txt file
to run services aactivate their environment <code>venv\activate\scripts</code> and then run the app.py file <code>python app.py<\code>
to complile the front end and host it using tomcat, first generate the .war file <code>mvn clean package<\code>, then move it to the webapps folder inside the tomcat`s installation folder
