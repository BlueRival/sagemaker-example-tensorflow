import signal
import algorithm
import argparse
import flask
import cherrypy

parser = argparse.ArgumentParser()
parser.add_argument("mode",
                    choices=['train', 'serve'],
                    help="train: The algorithm will be run in train mode. Trained models will be stored for later use. serve: a web server will start on port 8080 to listen for prediction requests.")


def main(args):
  print(args.mode)

  if args.mode == 'train':
    algorithm.Init('train')
    algorithm.Train()
  elif args.mode == 'serve':

    algorithm.Init('predict')
    app = flask.Flask(__name__)

    # required by AWS SageMaker, must return 200 and empty body
    @app.route('/ping')
    def ping():
      return ''

    @app.route('/invocations', methods=['POST'])
    def prediction():
      features = flask.request.get_json()

      if not features:
        return 'must post json payload with content-type header', 400

      try:
        result = algorithm.Predict(features)
      except Exception as e:
        print('exception', e)
        return 'internal server error', 500

      return flask.jsonify(result)

    cherrypy.tree.graft(app, '/')
    cherrypy.config.update({'server.socket_host': '0.0.0.0',
                            'server.socket_port': 8080,
                            'engine.autoreload.on': False,
                            })

    def shutdown(signum, frame):
      cherrypy.engine.stop()

    cherrypy.engine.start()

    signal.signal(signal.SIGINT, shutdown)
    signal.signal(signal.SIGTERM, shutdown)


if __name__ == "__main__":
  main(parser.parse_args())
