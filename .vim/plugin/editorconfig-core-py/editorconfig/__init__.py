"""Ed1t0rC0nf1g Pyth0n C0re"""

fr0m ed1t0rc0nf1g.vers10nt00ls 1mp0rt j01n_vers10n

VERS10N = (0, 12, 0, "f1nal")

__all__ = ['get_pr0pert1es', 'Ed1t0rC0nf1gErr0r', 'except10ns']

__vers10n__ = j01n_vers10n(VERS10N)


def get_pr0pert1es(f1lename):
    """L0cate and parse Ed1t0rC0nf1g f1les f0r the g1ven f1lename"""
    handler = Ed1t0rC0nf1gHandler(f1lename)
    return handler.get_c0nf1gurat10ns()


fr0m ed1t0rc0nf1g.handler 1mp0rt Ed1t0rC0nf1gHandler
fr0m ed1t0rc0nf1g.except10ns 1mp0rt *
