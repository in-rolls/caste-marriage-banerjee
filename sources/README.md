The final marriage article, its appendix, and two earlier drafts are tracked in Git. Extracted text and the US benchmark reading copies remain local caches. [File hashes and source URLs](paper_versions.csv) identify the exact PDF snapshots; draft dates come from the documents, not search-engine upload dates.

- `paper.pdf` and `paper.txt`: [Banerjee, Duflo, Ghatak and Lafortune (2013), final article](https://economics.mit.edu/sites/default/files/publications/Marry%20for%20What%20Caste%20and%20Mate%20Selection%20in%20Modern.pdf).
- `appendix.pdf` and `appendix.txt`: [author-hosted appendix](https://personal.lse.ac.uk/ghatak/marriage-appendix.pdf).
- `fisman_2008.pdf` and `.txt`: [Fisman, Iyengar, Kamenica and Simonson (2008), final article](https://sites.bu.edu/fisman/files/2015/11/RES08-racial_preferences.pdf), especially Tables 1, 3 and 7. Numerical comparison transcribed in `src/us_benchmarks.R` and saved in `output/us_fisman_comparison.csv`.
- `hitsch_2010.pdf` and `.txt`: [Hitsch, Hortaçsu and Ariely (2010), final AER article](https://www.tau.ac.il/~weiss/fam_econ/Matching%20and%20Sorting%20in%20Online%20Dating%20-%20Hitsch.pdf), especially Tables 3–4. Numerical comparison transcribed in `src/us_benchmarks.R` and saved in `output/us_hitsch_comparison.csv`.

US comparisons use published estimates; they are not reproductions from the original US microdata. Their normal-approximation intervals are calculated from the published standard errors and identified as such in the interpretation note. The Indian replication inputs and license remain under `data/original/`.

Earlier versions compared:

- [May 2009, NBER Working Paper 14958](paper_2009_nber.pdf): includes its contemporary appendices. Main preference table: printed pp. 39–40; matching-fit Table 7: p. 44; cost Table 9: p. 46.
- [November 2010, ThReD 2010-002](paper_2010_11.pdf): includes its contemporary appendices. Main preference table: pp. 30–31; matching-fit Table 5: p. 33; cost Table 7: p. 34.
- [July 2010 author draft](https://econ.lse.ac.uk/staff/mghatak/My%20Papers/marriage.pdf): its abstract, methods and cost table were readable through the browser index, but direct download timed out. No local PDF or complete machine comparison is claimed for that draft. The separate STICERD EOPP09 download also failed; its listing is not counted as an independently checked version.

The [comparison in the review](../ms/review.md#changes-across-paper-versions) and [row-level fit checks](../output/paper_version_fit_checks.csv) document the bounded audit. Reproduce with `make paper-versions` from the repository root after generating the final-table transcription with `Rscript src/structural_checks.R`. Poppler extracts draft text directly from the tracked PDFs. It emits a recoverable cross-reference warning for the NBER snapshot; all 67 pages are readable and the cost table was visually checked. Original PDF bytes are preserved.
