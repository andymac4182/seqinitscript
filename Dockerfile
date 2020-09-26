FROM datalust/seqcli:latest as seqcli


FROM datalust/seq:latest as Original
ENV ACCEPT_EULA=Y
ENV INITFILE=/init.sh
COPY --from=seqcli /bin/seqcli/ /bin/seqcli/
COPY *.sh /
