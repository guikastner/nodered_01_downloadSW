# Imagem base parametrizada pelo Terraform (arg NODE_RED_BASE_IMAGE)
ARG NODE_RED_BASE_IMAGE
FROM ${NODE_RED_BASE_IMAGE}

ARG ADMIN_PASSWORD_HASH
ARG VIEWER_PASSWORD_HASH

USER root
WORKDIR /usr/src/node-red

RUN npm install https://btcc.s3.dualstack.eu-west-1.amazonaws.com/widget-lab/npm/node-red-contrib-3dxinterfaces/dist/widget-lab-node-red-contrib-3dxinterfaces-6.4.2.tgz
RUN npm install node-red-contrib-axios
RUN npm install node-red-node-mysql
RUN npm install node-red-contrib-mongodb4@latest
RUN npm install node-red-contrib-postgresql
RUN npm install @flowfuse/node-red-dashboard


RUN mkdir -p /data/PDF \
  && mkdir -p /data/Solidworks \
  && mkdir -p /data/CATIAV5 \
  && mkdir -p /data/Excel \
  && chmod -R 777 /data/PDF /data/Solidworks /data/CATIAV5 /data/Excel \
  && chown -R node-red:node-red /data

COPY settings.js /usr/src/node-red/settings.js
RUN test -n "${ADMIN_PASSWORD_HASH}" && test -n "${VIEWER_PASSWORD_HASH}" \
  && sed -i "s|__ADMIN_PASSWORD_HASH__|${ADMIN_PASSWORD_HASH}|g; s|__VIEWER_PASSWORD_HASH__|${VIEWER_PASSWORD_HASH}|g" /usr/src/node-red/settings.js \
  && chown node-red:node-red /usr/src/node-red/settings.js

USER node-red
WORKDIR /usr/src/node-red

EXPOSE 1880

CMD ["npm", "start", "--", "--userDir", "/data", "--settings", "/usr/src/node-red/settings.js"]
