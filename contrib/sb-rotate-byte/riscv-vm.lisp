(in-package "SB-ROTATE-BYTE")

;;; 32-bit
(define-vop (%32bit-rotate-byte/c)
  (:policy :fast-safe)
  (:translate %unsigned-32-rotate-byte)
  (:note "inline 32-bit constant rotation")
  (:args (integer :scs (sb-vm::unsigned-reg) :target result))
  (:info count)
  (:arg-types (:constant (integer -31 31)) sb-vm::unsigned-num)
  (:temporary (:sc sb-vm::unsigned-reg) temp)
  (:results (result :scs (sb-vm::unsigned-reg)))
  (:result-types sb-vm::unsigned-num)
  (:generator 5
    (aver (/= count 0))
    (let ((count (if (plusp count)
                     count
                     (+ 32 count))))
      (inst slli temp integer count)
      (inst #-64-bit srli #+64-bit srliw result integer (- 32 count))
      (inst or result result temp)
      #+64-bit
      (progn
        (inst slli result result 32)
        (inst srli result result 32)))))

(define-vop (%32bit-rotate-byte)
  (:policy :fast-safe)
  (:translate %unsigned-32-rotate-byte)
  (:note "inline 32-bit rotation")
  (:args (count :scs (sb-vm::signed-reg))
         (integer :scs (sb-vm::unsigned-reg)))
  (:arg-types sb-vm::tagged-num sb-vm::unsigned-num)
  (:temporary (:sc sb-vm::signed-reg) temp)
  (:temporary (:sc sb-vm::signed-reg) count-temp)
  (:results (result :scs (sb-vm::unsigned-reg)))
  (:result-types sb-vm::unsigned-num)
  (:generator 10
    (inst slti count-temp count 0)
    (inst slli count-temp count-temp 5)
    (inst add count-temp count-temp count)
    (inst sll temp integer count-temp)
    (inst subi count-temp count-temp 32)
    (inst sub count-temp sb-vm::zero-tn count-temp)
    (inst #-64-bit srl #+64-bit srlw result integer count-temp)
    (inst or result result temp)
    #+64-bit
    (progn
      (inst slli result result 32)
      (inst srli result result 32))))

;;; 64-bit
(define-vop (%64bit-rotate-byte/c)
  (:policy :fast-safe)
  (:translate %unsigned-64-rotate-byte)
  (:note "inline 64-bit constant rotation")
  (:args (integer :scs (sb-vm::unsigned-reg) :target result))
  (:info count)
  (:arg-types (:constant (integer -63 63)) sb-vm::unsigned-num)
  (:temporary (:sc sb-vm::unsigned-reg) temp)
  (:results (result :scs (sb-vm::unsigned-reg)))
  (:result-types sb-vm::unsigned-num)
  (:generator 5
    (aver (not (= count 0)))
    (let ((count (if (plusp count)
                     count
                     (+ 64 count))))
      (inst slli temp integer count)
      (inst srli result integer (- 64 count))
      (inst or result result temp))))

(define-vop (%64bit-rotate-byte)
  (:policy :fast-safe)
  (:translate %unsigned-64-rotate-byte)
  (:note "inline 64-bit rotation")
  (:args (count :scs (sb-vm::signed-reg))
         (integer :scs (sb-vm::unsigned-reg)))
  (:arg-types sb-vm::tagged-num sb-vm::unsigned-num)
  (:temporary (:sc sb-vm::unsigned-reg) temp)
  (:temporary (:sc sb-vm::signed-reg) count-temp)
  (:results (result :scs (sb-vm::unsigned-reg)))
  (:result-types sb-vm::unsigned-num)
  (:generator 10
    (inst slti count-temp count 0)
    (inst slli count-temp count-temp 6)
    (inst add count-temp count-temp count)
    (inst sll temp integer count-temp)
    (inst subi count-temp count-temp 64)
    (inst sub count-temp sb-vm::zero-tn count-temp)
    (inst srl result integer count-temp)
    (inst or result result temp)))
