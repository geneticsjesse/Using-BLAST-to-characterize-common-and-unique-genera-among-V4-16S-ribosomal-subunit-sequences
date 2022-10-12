# Load relevant packages
module load StdEnv/2020
module load gcc/9.3.0
module load blast+/2.12.0

# Creating a new database from our new_reference.ft file
makeblastdb -in new_reference.ft -dbtype nucl -input_type fasta -out reference.fa

# Blasting distal lumen sequences against the reference database and telling blastn only to output the query ID, the subject title, as well as the bitscore in output format 6 and write all of that to a file named DL_match_uncleaned.txt
blastn -query DL_1.txt -db reference.fa -outfmt "6 qseqid stitle bitscore" -max_target_seqs 1 -out DL_match_uncleaned.txt

# Blasting proximal mucosa sequences against the reference database and telling blastn only to output the query ID, the subject title, as well as the bitscore in output format 6 and write all of that to a file named PM_match_uncleaned.txt
blastn -query PM_1.txt -db reference.fa -outfmt "6 qseqid stitle bitscore" -max_target_seqs 1 -out PM_match_uncleaned.txt

# Using sed to remove the _n from the genera names within the distal lumen and writing that to a new file called DL_match_clean.txt
# This ensures we don't overestimate the number of unique/shared genera between the distal lumen and proximal mucosa due to differences in strings that do not reflect true different genera
sed -E 's/([A-Z]+_[0-9]+\t[A-Za-z_ /0-9]+)_[0-9]+(\t[0-9]+)/\1\2/g' DL_match_uncleaned.txt > DL_match_clean.txt

# Using sed and looking at only the second match to ensure methods align
sed 's/_[0-9]//2' DL_match_uncleaned.txt > DL_match_clean2.txt

# Using sed to remove the _n from the genera names within the proximal mucosa and writing that to a new file called PM_match_clean.txt
# This ensures we don't overestimate the number of unique/shared genera between the distal lumen and proximal mucosa due to differences in strings that do not reflect true different genera
sed -E 's/([A-Z]+_[0-9]+\t[A-Za-z_ /0-9]+)_[0-9]+(\t[0-9]+)/\1\2/g' PM_match_uncleaned.txt > PM_match_clean.txt

# Using sed and looking at only the second match to ensure methods align
sed 's/_[0-9]//2' PM_match_uncleaned.txt > PM_match_clean2.txt

# Using cmp to ensure DL/PM_match_clean.txt and DL/PM_match_clean2.txt were identical
cmp --silent DL_match_clean.txt DL_match_clean2.txt || echo "files are different"
cmp --silent PM_match_clean.txt PM_match_clean2.txt || echo "files are different"

# Once I verified that the _clean.txt files had no _n's after the genus name and any roman numerals and digits preceeding the underscore were retained, I moved the contents of the DL/PM_match_clean.txt files to DL/PM_match.txt
mv DL_match_clean.txt DL_match.txt
mv PM_match_clean.txt PM_match.txt

# Question 1

# Using sed to look for line breaks after using cat -vet DL_1.txt to identify the delimeter as ^M and replacing them with a new line, counting all of the lines using grep, and then writing that to a new file
sed 's/^M/\n/g' DL_1.txt | grep '^>' | wc -l > DL_count.txt

# Using the combination of cat and grep to perform the sequence count a different way to ensure methods align
cat DL_1.txt | grep -o ASV | wc -l

# Using sed to look for line breaks after using cat -vet DL_1.txt to identify the delimeter as ^M and replacing them with a new line, counting all of the lines, and then writing that to a new file
sed 's/^M/\n/g' PM_1.txt | grep '^>' | wc -l > PM_count.txt

# Using the combination of cat and grep to perform the sequence count a different way to ensure methods align
cat PM_1.txt | grep -i -o ASV | wc -l

# Question 2

# Using grep to find ASV_0, ASV_202, and ASV_668 from DL_match.txt, cutting the second column (genus), and writing that to a new file
grep "ASV_0" DL_match.txt | cut -f2 > ASV_0_DL.txt
grep "ASV_202" DL_match.txt | cut -f2  > ASV_202_DL.txt
grep "ASV_668" DL_match.txt | cut -f2 > ASV_668_DL.txt

# Using grep to find ASV_0, ASV_202, and ASV_668 from PM_match.txt, cutting the second column (genus), and writing that to a new file
grep "ASV_0" PM_match.txt | cut -f2 > ASV_0_PM.txt
grep "ASV_155" PM_match.txt | cut -f2 > ASV_155_PM.txt
grep "ASV_558" PM_match.txt | cut -f2 > ASV_558_PM.txt

# Question 3

# Cutting the second (genus) column and sorting using the -u parameter to output only unique values of column 2 and writing that to a new file. These files will be used to determine common/unique sequences between the distal lumen and proximal mucosa
cut -f2 DL_match.txt | sort -u > DL_match_unique.txt
cut -f2 PM_match.txt | sort -u > PM_match_unique.txt

# Using grep, the -v parameter to select non matching lines, and the -f parameter to take patterns from a file (in this case PM_match_unique.txt) and look for any non-matching patterns in DL_match_unique.txt and writing that to a new file to determine the genera unique to the distal lumen
grep -vf PM_match_unique.txt DL_match_unique.txt > DL_unique.txt

# Counting the lines/number of unique values in DL_unique.txt and writing that to a new file
wc -l DL_unique.txt > DL_unique_count.txt

# Using grep, the -v parameter to select non matching lines, and the -f parameter to take patterns from a file (in this case DL_match_unique.txt) and look for any non-matching patterns in PM_match_unique.txt and writing that to a new file to determine the genera unique to the proximal mucosa
grep -vf DL_match_unique.txt PM_match_unique.txt > PM_unique.txt

# Counting the lines/number of unique values in PM_unique.txt and writing that to a new file
wc -l PM_unique.txt > PM_unique_count.txt

# Using grep and the -f parameter to take patterns from a file (in this case DL_match_unique.txt) and look for any patterns in PM_match_unique.txt and writing that to a new file to determine the shared genera between the distal lumen and proximal mucosa
grep -f DL_match_unique.txt PM_match_unique.txt > DL_PM_common.txt

# Counting the lines/number of unique values in DL_PM_common.txt and writing that to a new file
wc -l DL_PM_common.txt > DL_PM_common_count.txt

# Question 5

# Using sed to remove all spaces in DL/PM_match.txt as the spaces between Clostridium and the roman numerals were causing issues with sort, sorting by the smallest bitscore, taking the 10 smallest values, and writing that to a new file
sed 's/ //g' DL_match.txt | sort -k3 | head > DL_lowest10bitscore.txt

sed 's/ //g' PM_match.txt | sort -k3 | head > PM_lowest10bitscore.txt
