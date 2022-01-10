import torch
from lovasz_loss import lovasz_hinge


def dice_loss(logits, target):
    smooth = 1e-3
    prob  = torch.sigmoid(logits)


    intersection = torch.sum(prob*target)
    denominator  = torch.sum(prob) + torch.sum(target)
    
    dice = (2*intersection + smooth) / (denominator + smooth)
    dice_loss = 1. - dice
    return dice_loss


def criterion_lovasz_hinge_non_empty(criterion, logits_deep, y):
    batch,c,h,w = y.size()
    y2 = y.view(batch*c,-1)
    logits_deep2 = logits_deep.view(batch*c,-1)
    
    y_sum = torch.sum(y2, dim=1)
    non_empty_idx = (y_sum!=0)
    
    if non_empty_idx.sum()==0:
        return torch.tensor(0)
    else:
        loss  = criterion(logits_deep2[non_empty_idx], 
                          y2[non_empty_idx])
        loss += lovasz_hinge(logits_deep2[non_empty_idx].view(-1,h,w), 
                             y2[non_empty_idx].view(-1,h,w))
        return loss