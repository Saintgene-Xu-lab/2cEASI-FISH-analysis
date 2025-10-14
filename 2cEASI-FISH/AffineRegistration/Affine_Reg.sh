#! /bin/bash

ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=4
export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS
/mnt/nas10g/Users/XSJ/Progs/Local_Cluster/Script_Libs/ANTs2/bin/antsRegistration -v 1 -d 3 -r [/mnt/nas10g/Users/GLQ/Data/ProbeInterCleaved/Reg_XSJ/S1_Reg/S1_C2_Ref.nrrd,/mnt/nas10g/Users/GLQ/Data/ProbeInterCleaved/Reg_XSJ/S1_Reg/S1_C4.nrrd,0] \
-m MI[/mnt/nas10g/Users/GLQ/Data/ProbeInterCleaved/Reg_XSJ/S1_Reg/S1_C2_Ref.nrrd,/mnt/nas10g/Users/GLQ/Data/ProbeInterCleaved/Reg_XSJ/S1_Reg/S1_C4.nrrd,1,64] \
-t Translation[0.2] -c [10000x10000x10000x10,5.e-5,3] -s 3x2x0x0vox -f 8x4x2x1 \
-m GC[/mnt/nas10g/Users/GLQ/Data/ProbeInterCleaved/Reg_XSJ/S1_Reg/S1_C2_Ref.nrrd,/mnt/nas10g/Users/GLQ/Data/ProbeInterCleaved/Reg_XSJ/S1_Reg/S1_C4.nrrd,1] \
-t Affine[0.1] -c [60x30x10,1.e-5,3] -s 2x1x0vox -f 4x2x1 \
-n Linear -o [/mnt/nas10g/Users/GLQ/Data/ProbeInterCleaved/Reg_XSJ/S1_Reg/ImgWarp/S1_C4,/mnt/nas10g/Users/GLQ/Data/ProbeInterCleaved/Reg_XSJ/S1_Reg/ImgWarp/S1_C4_Reg.nii]
