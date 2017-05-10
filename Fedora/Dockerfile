########################################################################
#                   JBoss Developer Studio via HTML5                   #
########################################################################

FROM fedora:25

MAINTAINER Peter Larsen <plarsen@redhat.com>

LABEL vendor="Red Hat"
LABEL version="0.1"
LABEL description="Fedora with X11 base"

RUN    dnf -y update \
    && dnf -y install \
           gettext \
           gtk3 \
           java-1.8.0-openjdk-devel \
           liberation-sans-fonts \
           webkitgtk3 \
           maven \
           nss_wrapper \
           openbox \
           tigervnc-server \
           wmctrl \
           origin-clients \
    && dnf -y clean all

USER root

