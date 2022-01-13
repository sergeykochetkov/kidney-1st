
for s in src/04_data_preparation_pseudo_label/04_01_kaggle_data/result/04_01/ src/04_data_preparation_pseudo_label/04_02_kaggle_data_shift/result/04_02/ src/04_data_preparation_pseudo_label/04_03_dataset_a_dib/result/04_03/ src/04_data_preparation_pseudo_label/04_05_hubmap_external/result/04_05/ src/04_data_preparation_pseudo_label/04_06_hubmap_external_shift/result/04_06/ src/04_data_preparation_pseudo_label/04_07_carno_zhao_label/result/04_07/ src/04_data_preparation_pseudo_label/04_08_carno_zhao_label_shift/result/04_08/
do
  b=$(basename $s)
  aws s3 cp $s s3://kochetkov-kidney/kidney-1st/$b --recursive
done
