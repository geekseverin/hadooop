FROM hadoop-base:latest

COPY start-master.sh /start-master.sh
RUN chmod +x /start-master.sh

EXPOSE 9870 8088 19888 8080 7077

CMD ["/start-master.sh"]