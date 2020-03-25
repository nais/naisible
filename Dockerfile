FROM navikt/ansible-playbook:2.8.5

RUN deluser --remove-home jenkins

RUN addgroup -g 991 jenkins
RUN adduser -S -u 595 -G jenkins jenkins
