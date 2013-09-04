/********************************************************************
* �� �� ����ExtInt_test.c
* ��    �ܣ�ʹ���ⲿ�����жϽ���LED�Ŀ��ƣ�ÿ����һ�ΰ����ж�ʱ����ȡ�����е�LED��ע����޹ؽ�Ҫ����������жϷ�������⴦����Ҫ����C�⺯������Printf()����ʱ��Ϊ�������������е�ʱ���޷�Ԥ֪������Ҫ���и���������ڵ���ʱ�������޷�Ԥ֪�жϷ���ʱ�䣬�������жϷ�����������öϵ㣬Ȼ�󵥲����ԡ�
*           
* ˵    ��������KEY�۲���Ӧ��LED��״̬��Ҫȥ�ĸ�����ȫ�����£�����
********************************************************************/
#include <stdio.h>
#include "system.h"
#include "altera_avalon_pio_regs.h"
#include "alt_types.h"
#include "sys/alt_irq.h"
#include "priv/alt_busy_sleep.h"

#define   LEDCON   0xff          // 
#define   KEYCON   0xff          //

/******************************************************************
*      ��Ӳ����صĺ궨�壬�û�����ʵ������޸�
******************************************************************/
// �û���Ӳ��������������ַ,��SYSTEM�ж���,�û���Ҫ���ݲ�ͬ���������޸Ĵ˴�
#ifndef KEY_PIO_BASE             //����KEY_PIO�˵Ļ���ַ
#define KEY_PIO_BASE 0xffffffff //user's definition here
#endif

#if KEY_PIO_BASE == 0xffffffff
#error "No definition of KEY_PIO core.\n"
#endif

#ifndef KEY_PIO_IRQ             //����KEY_PIO�˵��жϺ�
#define KEY_PIO_IRQ 0xffff //user's definition here
#endif

#if KEY_PIO_IRQ == 0xffff
#error "No definition of KEY_PIO_IRQ.\n"
#endif

#ifndef LED_PIO_BASE             //����LED_PIO�˵Ļ���ַ
#define LED_PIO_BASE 0xfffffffe //user's definition here
#endif

#if LED_PIO_BASE == 0xfffffffe
#error "No definition of LED_PIO core.\n"
#endif

volatile alt_u32 done = 0;                   // �ź�����֪ͨ�ⲿ�ж��¼�����

/********************************************************************
* ��    �ƣ�KeyDown_interrupts()
* ��    �ܣ��������¼��жϷ����ӳ��򣬵�������ʱ��ͨ��done��־
*           ��֪���
* ��ڲ�����context��һ�����ڴ����ж�״̬�Ĵ�����ֵ������δʹ�� 
*           id���жϺţ�����δʹ��
* ���ڲ�������
********************************************************************/
static void KeyDown_interrupts(void* context , alt_u32 id)
{ 
   /* ���жϲ���Ĵ��� */
   IOWR_ALTERA_AVALON_PIO_EDGE_CAP(KEY_PIO_BASE, 0);
   /* ֪ͨ�ⲿ���ж��¼����� */
   done++;
}
/********************************************************************
* ��    �ƣ�InitPIO()
* ��    �ܣ���ʼ��LED_PIOΪ�����KEYΪ���룬���жϣ�����ز���Ĵ���
* ��ڲ�������
* ���ڲ�������
********************************************************************/
void InitPIO(void)
{ 
/* ��ʼ��LED_PIOΪ�����KEYΪ���� */
IOWR_ALTERA_AVALON_PIO_DIRECTION(LED_PIO_BASE, LEDCON);
IOWR_ALTERA_AVALON_PIO_DIRECTION(KEY_PIO_BASE, 0x00);
/* ��KEY���ж� */
IOWR_ALTERA_AVALON_PIO_IRQ_MASK(KEY_PIO_BASE, KEYCON);
/* ����ز���Ĵ��� */ 
IOWR_ALTERA_AVALON_PIO_EDGE_CAP(KEY_PIO_BASE, 0x00);
/* ע���жϷ����ӳ��� */
alt_irq_register(KEY_PIO_IRQ, NULL, KeyDown_interrupts); 
}

/********************************************************************
* ��    �ƣ�main()
* ��    �ܣ��ȴ������жϣ������������Ӧ��LED��
********************************************************************/
int main(void)
{      
    volatile alt_u32 key_state,old_state,new_state;
    old_state = 0x00;
    IOWR_ALTERA_AVALON_PIO_DATA(LED_PIO_BASE, old_state);//��ʼ��LEDȫ��
    InitPIO();
    while(1) 
    { 
       if(0 != done)
       {
          /* �ж��¼�������1 */
          done--;
          alt_busy_sleep(5000); //��ʱ5ms
          key_state = IORD_ALTERA_AVALON_PIO_DATA(KEY_PIO_BASE)&KEYCON;
          if(key_state == 0xff)   //������ɶ�������������ж������
             continue;
        
          new_state = ~(old_state ^ key_state); // �ĸ�����ȫ������ʱLEDȡ��
          old_state = new_state;                // ����LED��״̬
          IOWR_ALTERA_AVALON_PIO_DATA(LED_PIO_BASE, new_state);
       }
    }
    return(0);
}


