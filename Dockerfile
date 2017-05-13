########################################################################
#                   JBoss Developer Studio via HTML5                   #
########################################################################

FROM bit4man/fedorax11:0.1

MAINTAINER Peter Larsen <plarsen@redhat.com>

LABEL vendor="Red Hat"
LABEL version="0.1"
LABEL description="JBoss Developer Studio IDE - from Rich Lucente"

ENV HOME /home/jbdsuser

USER root

# Create installation directory and set the openbox window manager
# configuration for all users
RUN set -x \
    && mkdir -p /usr/share/devstudio \
    && echo 'export DISPLAY=:1' >> /etc/xdg/openbox/environment \
    && echo "/usr/share/devstudio/devstudio -nosplash -data ${HOME}/workspace &" >> /etc/xdg/openbox/autostart

# Add the installation configuration file
ADD resources/InstallConfigRecord.xml /usr/share/devstudio/

# Install JBoss Developer Studio.  The needed files will be downloaded
# from the provided URL. The reason for this is to not include the
# JBDS distribution in the docker layer since this image is going to
# be quite large.  If the docker ADD instruction is used the file
# becomes a permanent part of that layer, bloating the size of an
# already large image.
#
# The for loops scan the JBDS installation for native libraries and
# then remove any that are already present in the system libraries.
# Redundant libraries that varied by version resulted in JBDS
# crashes.
#
# Finally, the last command installs the JBoss integration tooling.
#
RUN    mkdir -p /tmp/resources \
    && cd /tmp/resources \
    && curl -L -o $JBDS_JAR $INSTALLER_URL \
    && java -jar $JBDS_JAR /usr/share/devstudio/InstallConfigRecord.xml \
    && cd /usr/share/devstudio \
    && for ext in so chk; do \
         for jbdslib in `find . -name "*.$ext"`; do \
           jbdslib_basename=`basename $jbdslib`; \
           for syslibdir in /lib64 /usr/lib64; do \
             for dummy in `find $syslibdir -name $jbdslib_basename`; do \
               [ -f $jbdslib ] && rm -f $jbdslib; \
             done; \
           done; \
         done; \
       done \
    && /usr/share/devstudio/devstudio \
         -clean -purgeHistory \
         -application org.eclipse.equinox.p2.director \
         -noSplash \
         -repository https://devstudio.redhat.com/10.0/stable/updates/ \
         -i org.fusesource.ide.camel.editor.feature.feature.group,org.fusesource.ide.core.feature.feature.group,org.jboss.tools.fuse.transformation.feature.feature.group,org.fusesource.ide.jmx.feature.feature.group,org.fusesource.ide.server.extensions.feature.feature.group,org.switchyard.tools.feature.feature.group,org.switchyard.tools.bpel.feature.feature.group,org.switchyard.tools.bpmn2.feature.feature.group,org.teiid.datatools.connectivity.feature.feature.group,org.teiid.designer.feature.feature.group,org.teiid.designer.runtime.feature.feature.group,org.teiid.designer.teiid.client.feature.feature.group \
    && rm -fr /tmp/resources

# This script starts and cleanly shuts down JBDS and the Xvnc server
ADD resources/start.sh /usr/local/bin/

# This file is used to create a temporary passwd file for use by
# the NSS wrapper so that the openbox window manager can launch
# correctly.  OCP will use a non-deterministic user id, so we have
# to provide a valid passwd entry for that UID for openbox
ADD resources/passwd.template /usr/local/share/

# Create the home directory and set permissions
RUN    mkdir -p ${HOME} \
    && chmod a+rwX ${HOME} \
    && chmod a+rx /usr/local/bin/start.sh \
    && chmod a+r /usr/local/share/passwd.template

EXPOSE 5901

USER 1000

CMD /usr/local/bin/start.sh

# No volume support yet, so everything in /home/jbdsuser is ephemeral.
# Eventually this can be a mounted persistent volume so each user can
# have a persistent maven repository, workspace, etc.
