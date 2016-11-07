import sys
import json
import datetime
import argparse
import yattag

class EpisodeNumber():
    # Takes something that looks like this: Season 03, Episode 03
    def __init__(self, episode_number_string):
        ep = episode_number_string.split(',')
        self.season = int(ep[0].strip('Season '))
        self.episode = int(ep[1].strip(' Episode '))

    def __str__(self):
        return "Season {}, Episode {}".format(self.season, self.episode)

class Episode():
    def __init__(self, show, d):
        self.json_repr = d
        self.show = show
        self.name = d['name']
        self.date = datetime.datetime.strptime(d['aire_date'], '%B %d, %Y').date()
        self.episode_number = EpisodeNumber(d['episode'])

    def __cmp__(self, other):
        return cmp(self.show, other.show) or cmp(self.date, other.date)
            
    def __repr__(self): 
        return str(self.json_repr)
        
    def add_html(self, doc):
        doc.text(str(self.episode_number))
        doc.stag('br')
        with doc.tag('span', klass="aire_date"):
            doc.text(datetime.datetime.strftime(self.date, '%B %d, %Y'))
        doc.stag('br')
        # asis so yattag doesn't escape my already-escaped characters
        doc.asis(self.name)

class Show():
    def __init__(self, show, episodes, last_seen):
        self.show = show
        self.episodes = sorted(episodes)
        self.last_seen = last_seen

    def last_seen_index(self):
        if last_seen is None: 
            return None
        else:
            return next((idx for (idx, ep) in enumerate(sorted(self.episodes)) if ep.name == self.last_seen), None)

    def add_html(self, doc, today):
        index_of_last_seen = self.last_seen_index()
        print >> sys.stderr, "index of", self.last_seen, ":", index_of_last_seen
        eps = reversed([ (idx <= index_of_last_seen, ep) for (idx, ep) in enumerate(self.episodes) ])
        doc.line('h3', self.show)
        with doc.tag('div', style="white-space:nowrap"):
            for (seen, ep) in eps:
                klass = 'seen' if seen else ('new' if ep.date < today else 'future')
                with doc.tag('div', klass=' '.join(["box", klass])):
                    ep.add_html(doc)
        
def load_episodes(show, filename): 
    return [ Episode(show, json.loads(line)) for line in file(filename) ]

# b99_eps = load_episodes('Brooklyn 99', 'b99.json')
# from random import shuffle
# shuffle(b99_eps)
# b99_eps = sorted(b99_eps)
# last_seen = 'Greg and Larry'

# show = Show('Brooklyn 99', b99_eps, last_seen)
# print show.last_seen_index()
# print show.html()

shows = [
    ('Ballers', 'ballers', 'Game Day'),
    ('Broad City', 'broad-city', 'Jews on a Plane'),
    ('Game of Thrones', 'game-of-thrones', 'The Winds of Winter'),
    ('Last man on earth', 'last-man-on-earth', 'Five Hoda Kotbs'),
    ('Modern Family', 'modern-family', 'Halloween 4: The Revenge of Rod Skyhook'),
    ('Brooklyn 99', 'brooklyn-99', 'Coral Palms, Pt. 1'),
    #('Narcos', 'narcos', None),
    #('South Park', 'south-park', None),
    #('The League', 'the-league', None),
    ('Westworld', 'westworld', None),
    ('The Night Of', 'the-night-of', None),
    ('It\'s aways sunny', 'its-always-sunny-in-philadelphia', None),
]

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Create tv-guide html page.')
    parser.add_argument('-o', '--out',
                        nargs='?', 
                        type=argparse.FileType('w'),
                        default=sys.stdout,
                        help='output file (or stdout)',
    )
    parser.add_argument('-i', '--import',
                        dest="imports",
                        action='append',
                        default=[],
                        help='import in header',
    )
    parser.add_argument('-c', '--css', 
                        dest="css_files",
                        action='append',
                        default=[],
                        help='css file to include in header',
    )
    args = parser.parse_args()

    doc = yattag.Doc()
    with doc.tag('head'):
        for imprt in args.imports:
            doc.stag('link', rel="import", href=imprt)
        for css in args.css_files:
            doc.stag('link', rel="stylesheet", type="text/css", href=css)

    with doc.tag('body'):
        today = datetime.date.today()
        for (show, episode_file, last_seen) in shows:
            with doc.tag('div'):
                print >> sys.stderr, "processing show", show
                episodes = load_episodes(show, 'show-episodes/' + episode_file + '.json')
                show = Show(show, episodes, last_seen)
                show.add_html(doc, today)
    
    # write out the (indented) document
    args.out.write(yattag.indent(doc.getvalue()))
