
# page server

or web server or front-end server
this module take any http request and output required html parsed template to client

# components (chat - pad - game)

Apart from the main page that gather all three functionnalities needed to play;
things are split in three independent domain:
- chat
- gamepad/controller
- game display

and each time, each part is usually composed of three things:
- a basic html template (*.html.eex) that just call a js module script
- a js module script that setup whatever is needed to provide the functionnality
- a web framework/library (gost) that is used by each component
