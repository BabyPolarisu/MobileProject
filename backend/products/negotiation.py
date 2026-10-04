from rest_framework.negotiation import DefaultContentNegotiation

class IgnoreClientContentNegotiation(DefaultContentNegotiation):
    """
    Always select the first renderer (JSONRenderer), ignoring whatever Accept header
    the client sent (e.g. browser default text/html).
    This guarantees API endpoints always return clean JSON without 406 or HTML pages.
    """
    def select_renderer(self, request, renderers, format_suffix=None):
        return (renderers[0], renderers[0].media_type)
