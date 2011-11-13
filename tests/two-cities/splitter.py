book_file = open('two-cities.txt')
book = book_file.read()
book_file.close()

chapters = [
    'I. The Period',
    'II. The Mail',
    'III. The Night Shadows',
    'IV. The Preparation',
    'V. The Wine-shop',
    'VI. The Shoemaker',
    'I. Five Years Later',
    'II. A Sight',
    'III. A Disappointment',
    'IV. Congratulatory',
    'V. The Jackal',
    'VI. Hundreds of People',
    'VII. Monseigneur in Town',
    'VIII. Monseigneur in the Country',
    'IX. The Gorgon\'s Head',
    'X. Two Promises',
    'XI. A Companion Picture',
    'XII. The Fellow of Delicacy',
    'XIII. The Fellow of No Delicacy',
    'XIV. The Honest Tradesman',
    'XV. Knitting',
    'XVI. Still Knitting',
    'XVII. One Night',
    'XVIII. Nine Days',
    'XIX. An Opinion',
    'XX. A Plea',
    'XXI. Echoing Footsteps',
    'XXII. The Sea Still Rises',
    'XXIII. Fire Rises',
    'XXIV. Drawn to the Loadstone Rock',
    'I. In Secret',
    'II. The Grindstone',
    'III. The Shadow',
    'IV. Calm in Storm',
    'V. The Wood-Sawyer',
    'VI. Triumph',
    'VII. A Knock at the Door',
    'VIII. A Hand at Cards',
    'IX. The Game Made',
    'X. The Substance of the Shadow',
    'XI. Dusk',
    'XII. Darkness',
    'XIII. Fifty-two',
    'XIV. The Knitting Done',
    'XV. The Footsteps Die Out For Ever'
]

chapters_text = []

def put_chapter(this_chapter, next_chapter, text):
    split_text = text.split(next_chapter, 1)
    if len(split_text) != 2:
        raise Exception('Failed to find delimiter: \'%s\'' % next_chapter)
    print 'Putting chapter \'%s\'. Length is %d' % (this_chapter,
                                                    len(split_text[0]))
    chapters_text.append( (this_chapter, split_text[0]) )
    return split_text[1]

prev_chapter = None
for chapter in chapters:
    if prev_chapter is None:
        prev_chapter = chapter
        continue
    book = put_chapter(prev_chapter, chapter, book)
    prev_chapter = chapter

print 'Adding final chapter \'%s\'. Length is %d' % (chapters[-1], len(book))
chapters_text.append( (chapters[-1], book) )

for chapter in chapters_text:
    output_file = open('output/'+chapter[0]+'.txt', 'w')
    output_file.write(chapter[1])
    output_file.close()
