#PBS -N pace-adam-test
#PBS -q cygnus-hp-small
#PBS -o /nv/hp11/aotte6/scratch/pace_test/pace-adam-test.o
#PBS -e /nv/hp11/aotte6/scratch/pace_test/pace-adam-test.e
#PBS -m abe
#PBS -l walltime=00:05:00
#PBS -l nodes=1:ppn=1
#PBS -l mem=2gb

echo "Does this segfault?"

/nv/hp11/aotte6/data/veritas/vegas/v2_4_root5.26/vegas/bin/vaStage1 -config=/nv/hp11/aotte6/VERITAS/Crab/VTSCrabPaper/calibration/2010/CutsConfigs//stage1.cfg /nv/hp11/aotte6/data/veritas/raw_data/d20101108/53103.laser.cvbf /nv/hp11/aotte6/data/veritas/calibdata/v2_4_root5.26//d20101108//53103.laser.root

