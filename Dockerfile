FROM java:6-jre

ENV CATALINA_HOME /usr/local/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH
RUN mkdir -p "$CATALINA_HOME"
WORKDIR $CATALINA_HOME

# see https://www.apache.org/dist/tomcat/tomcat-8/KEYS
RUN set -ex \
	&& for key in \
		05AB33110949707C93A279E3D3EFE6B686867BA6 \
		07E48665A34DCAFAE522E5E6266191C37C037D42 \
		47309207D818FFD8DCD3F83F1931D684307A10A5 \
		541FBE7D8F78B25E055DDEE13C370389288584E7 \
		61B832AC2F1C5A90F0F9B00A1C506407564C17A3 \
		79F7026C690BAA50B92CD8B66A3AD3F4F22C4FED \
		80FF76D88A969FE46108558A80B953A041E49465 \
		8B39757B1D8A994DF2433ED58B3A601F08C975E5 \
		A27677289986DB50844682F8ACB77FC2E86E29AC \
		A9C5DF4D22E99998D9875A5110C01C5A2F6059E7 \
		B3F49CD3B9BD2996DA90F817ED3873F5D3262722 \
		DCFD35E0BF8CA7344752DE8B6FB21E8933C60243 \
		F3A04C595DB5B6A5F1ECA43E3B7BBB100D811BBE \
		F7DA48BB64BCB84ECBA7EE6935CD23C10D498E23 \
	; do \
		gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
	done

ENV TOMCAT_MAJOR 6
ENV TOMCAT_VERSION 6.0.45
ENV TOMCAT_TGZ_URL https://www.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz

RUN set -x \
	&& curl -fSL "$TOMCAT_TGZ_URL" -o tomcat.tar.gz \
	&& curl -fSL "$TOMCAT_TGZ_URL.asc" -o tomcat.tar.gz.asc \
	&& gpg --batch --verify tomcat.tar.gz.asc tomcat.tar.gz \
	&& tar -xvf tomcat.tar.gz --strip-components=1 \
	&& rm bin/*.bat \
	&& rm tomcat.tar.gz*

EXPOSE 8080

RUN	apt-get update && \
	apt-get install -y postgresql-client netcat unzip gettext-base

WORKDIR /tmp
ENV OPENMAINT_ZIP_URL http://downloads.sourceforge.net/project/openmaint/1.0/openmaint-1.0-2.3.1.zip
RUN set -x \
	&& curl -fSL "$OPENMAINT_ZIP_URL" -o openmaint.zip \	
	&& unzip openmaint.zip  \
	&& rm openmaint.zip \
	&& mv openmaint* openmaint
COPY configuration /tmp/openmaint/configuration
COPY docker-entrypoint.sh /
WORKDIR $CATALINA_HOME

## OPENMAINT CONFIGURATION {

ENV OPENMAINT_DEFAULT_LANG=en

ENV DB_USER=postgres \
	DB_PASS=test \	
	DB_HOST=postgres \
	DB_PORT=5432 \
	DB_NAME=openmaint

ENV BIM_ACTIVE=false \
	BIM_URL=http://bimserver:8080/bimserver \
	BIM_USER=admin@example.org \
	BIM_PASSWORD=bimserver

ENV GIS_ENABLED=false \
	GEOSERVER_ON_OFF=off \
	GEOSERVER_URL=http://geoserver:8080/geoserver \
	GEOSERVER_USER=admin \
	GEOSERVER_PASSWORD=geoserver \
	GEOSERVER_WORKSPACE=cmdbuild

## }

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["openmaint"]